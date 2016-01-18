// $Id: inode.cpp,v 1.12 2014-07-03 13:29:57-07 - - $

#include <iostream>
#include <stdexcept>
#include <vector>
#include <string>
#include <cstdlib>
#include <iomanip>
using namespace std;

#include "debug.h"
#include "inode.h"


int inode::next_inode_nr {1};

inode_state::inode_state(inode_ptr& a, 
             inode_ptr& b,inode_ptr& c):
    root(a), parent(b), cwd(c){}


inode::inode(inode_t init_type):
   inode_nr (next_inode_nr++), type (init_type)
{
   switch (type) {
      case PLAIN_INODE:
           contents = make_shared<plain_file>();
           break;
      case DIR_INODE:
           contents = make_shared<directory>();
           break;
   }
   DEBUGF ('i', "inode " << inode_nr << ", type = " << type);
}

int inode::get_inode_nr() const {
   
   DEBUGF ('i', "inode = " << inode_nr);
   return inode_nr;
}

int inode::get_inode_type(){
   int itype = 100;
   switch(type){
     case PLAIN_INODE :
       itype = 0;
       break;
     case DIR_INODE:
       itype = 1;
       break;
     default:
      throw invalid_argument ("wrong type");  
   } 
   DEBUGF ('i', "inode " << inode_nr << ", type = " << type);
   return itype;
}

file_base_ptr& inode::get_file_ptr(){
   return contents;
}

//helper func to show information
void inode::printInfo(){
  cout<< setw(6)<<inode_nr;
  cout<<"  ";
  cout<< setw(6)<< get_inode_size();
  cout<<"  ";
  DEBUGF ('i', "inode = " << inode_nr);
}

void inode::print_direc_info(){//print a single dir
  string name="";
  string tempname="";
  inode_ptr cwdptr = nullptr;
  inode_ptr parentptr = nullptr;
  directory_ptr dptr= directory_ptr_of(contents);
  for(;;){
     cwdptr    = dptr->find_address(".");
     parentptr = dptr->find_address("..");
     if(cwdptr==parentptr) {
        tempname="/";
        name.insert(0,tempname);
        break;
      }
     else{
       tempname = parentptr->find_inode_name(cwdptr);
       name.insert(0, tempname);
      }
     dptr = parentptr->get_directory_ptr();
     
   }
  if(name.size() !=1){ 
     size_t found = name.find_last_of("/");
     name.erase(found,1);
   }
  cout<<name<<":"<<endl;
  dptr= directory_ptr_of(contents);
  dptr->print_direc_content();
  DEBUGF ('i', "inode " << inode_nr << ", type = " << type);
}


void inode::recur_print_direc(){//print subdirectory
   directory_ptr dptr= directory_ptr_of(contents);
   inode_ptr currentNode = dptr->find_address(".");
   currentNode->print_direc_info();
   for(auto it = dptr->dirents.begin();
                  it!=dptr->dirents.end();it++){
     string name = it->first;
     if(name.compare(".")==0)
        continue;
     if(name.compare("..")==0)
        continue;
     int type = it->second->get_inode_type();
     if (type ==1)
       it->second->recur_print_direc(); 
    }
    DEBUGF ('i', "inode " << inode_nr << ", type = " << type);
}

void inode::print_direc_info(const string& str){
  directory_ptr dptr= directory_ptr_of(contents);
  cout<<str<<":"<<endl;
  dptr->print_direc_content();
}

int inode::get_inode_size(){
  int nodesize=0;
  plain_file_ptr fileptr=nullptr;
  directory_ptr direcptr=nullptr;
  switch(type){
     case PLAIN_INODE:
       fileptr= plain_file_ptr_of (contents); 
       nodesize = fileptr->size();
       break;
     case DIR_INODE:
       direcptr = directory_ptr_of(contents);
       nodesize = direcptr->size();
       break;
   }
   DEBUGF ('i', "inode = " << inode_nr); 
   return nodesize;
}

//
void inode::push_dot(const string& str,inode_ptr& inodeptr){
  if(type ==PLAIN_INODE)
     return;
  
  directory_ptr dptr = directory_ptr_of(contents); 
  dptr->push_map(str, inodeptr);
  DEBUGF ('i', str);
}

//remove a single plain file or empty direc file
void inode::pop_node(const string& str){
  inode_ptr inodeptr=nullptr;
  plain_file_ptr pptr=nullptr;
  file_base_ptr fptr=get_file_ptr();
  directory_ptr dptr= directory_ptr_of(fptr);
  inodeptr = dptr->find_address(str);
  if(inodeptr==nullptr){
    throw invalid_argument ("No such file");
   }
  if(inodeptr->get_inode_size()<=2 &&
     inodeptr->get_inode_type()==1){
    dptr->remove(str);
    DEBUGF ('i',str); 
    return;
   }
  else if(inodeptr->get_inode_type()==0){
    //pptr = inodeptr->get_plainfile_ptr();
    //pptr->remove_file();
    dptr->remove(str);
    DEBUGF ('i',str);
    return;
  }   
}

//remove content of a direc  
void inode::pop_direc_node(){
  inode_ptr inodeptr=nullptr;
  plain_file_ptr pptr=nullptr;  
  file_base_ptr fptr= get_file_ptr();
  directory_ptr dptr= directory_ptr_of(fptr);
  inode_ptr cwdptr = dptr->find_address(".");
  inode_ptr parentptr=dptr->find_address("..");
  //int type;
  for(auto it=dptr->dirents.begin(); 
      it!= dptr->dirents.end();++it){
      string temp = it->first;
       if(temp.compare(".")==0)
           continue;
       if(temp.compare("..")==0)
           continue;
       //cwdptr->pop_node(temp);
         dptr->dirents.erase(it);
        
   }
  if(cwdptr!=parentptr){//cwd not root 
    string name = parentptr->find_inode_name(cwdptr);
    parentptr->pop_node(name);
  }
}

void inode::recur_pop_direc(){
    inode_ptr inodeptr=nullptr;
    
    directory_ptr dptr= directory_ptr_of(contents);
    inodeptr=dptr->find_address(".");
    
    for(auto it=dptr->dirents.begin();
      it!= dptr->dirents.end();++it){
       string temp = it->first;
     if(temp.compare(".")==0)
         continue;
     if(temp.compare("..")==0)
         continue;
     int type = it->second->get_inode_type();
     if(type ==1)
       it->second->recur_pop_direc();
       
     }
   inodeptr->pop_direc_node();
}

inode_ptr inode::find_inode_addr(const string& str){
   directory_ptr dptr = directory_ptr_of(contents);
   DEBUGF ('i',str);   
   return dptr->find_address(str);
}

inode_ptr inode::find_inode_addr(const wordvec& path,
                             inode_ptr& cwdptr){
    int size = path.size();
   // wordvec pathname = path; 
    inode_ptr workptr = cwdptr;
    inode_ptr target = nullptr;
    for(int i=0; i<size; ++i){
       target = workptr->find_inode_addr(path[i]);
       if(target ==nullptr)
          break;
       workptr=target;
    }
    DEBUGF ('i',path);
    return target;
}


string inode::find_inode_name(inode_ptr& inodeptr){
  string name=" ";
  directory_ptr dptr = directory_ptr_of(contents);
   
  for(auto it =dptr->dirents.begin();
      it!= dptr->dirents.end(); it++){
     inode_ptr temp= it->second;
      if(temp ==inodeptr){
        name = it->first;
        break;
        }      
    }
    return name;
}

//from one inode find its parent inode address
inode_ptr inode::find_parent_inodeptr(){
  directory_ptr dptr = directory_ptr_of(contents);
  return dptr->find_address("..");
}


plain_file_ptr inode::get_plainfile_ptr(){
  return plain_file_ptr_of(contents);
}

directory_ptr inode::get_directory_ptr(){
  return directory_ptr_of(contents);
}

plain_file_ptr plain_file_ptr_of (file_base_ptr ptr) {
   plain_file_ptr pfptr = dynamic_pointer_cast<plain_file> (ptr);
   if (pfptr == nullptr) throw invalid_argument ("plain_file_ptr_of");
   return pfptr;
}

directory_ptr directory_ptr_of (file_base_ptr ptr) {
   directory_ptr dirptr = dynamic_pointer_cast<directory> (ptr);
   if (dirptr == nullptr) throw invalid_argument ("directory_ptr_of");
   return dirptr;
}


size_t plain_file::size() const {
   size_t size {0};
   if(data.size()==0)
      return 0;
   for(size_t i =0; i< data.size(); i++)
       size += data[i].size();
   size =size + data.size()-1;
    
   //cout << "size is "<< size <<endl;
   
   DEBUGF ('i', "size = " << size);
   return size;
}

const wordvec& plain_file::readfile() const {
   for(auto it: data)
     cout<< it <<' ' ;
   DEBUGF ('i', data);
   return data;
}

void plain_file::writefile (const wordvec& words) {
   data = words;
   DEBUGF ('i', words);
}

void plain_file::remove_file(){
   data.clear();
 }

size_t directory::size() const {
   size_t size {0};
   size = dirents.size();
   //cout << "directry size is " << size <<endl;
   DEBUGF ('i', "size = " << size);
   return size;
}

void directory::remove (const string& filename) {
   //map<string,inode_ptr>::iterator it;
   auto it = dirents.find(filename);
   if (it == dirents.end()){
     throw invalid_argument ("Can't find file");
     //complain()<<"can't find file "<< filename<<endl;
     //return; 
   }
   dirents.erase(it);
   DEBUGF ('i', filename);
}


inode& directory::mkdir(const string& dirname){
   
   inode_ptr newptr (new inode(DIR_INODE));
   dirents.insert(pair<string,inode_ptr> (dirname, newptr));
    //newInodeptr->inode_nr_increase();
   //newptr->contents->dirents.insert(pair<string,inode_ptr>(".", newptr));
   //newptr->contents->dirents.insert(pair<string,inode_ptr>("..", newptr));
   file_base_ptr abaseptr=newptr->get_file_ptr();
   directory_ptr adirecptr=directory_ptr_of(abaseptr);
   adirecptr->push_map(".",newptr);
   adirecptr->push_map("..",newptr);
   DEBUGF ('i', dirname);
   return *newptr;
} 

void directory::push_map(const string& name, inode_ptr& inodeptr){
   dirents.insert(pair<string,inode_ptr>(name, inodeptr));
   //cout<<"directory size is "<<dirents.size() << endl;
   DEBUGF ('i', name);
}



//find file and check the type or make a new file
inode& directory::mkfile (const string& filename){
   map<string,inode_ptr>::iterator it;
   it = dirents.find(filename);
   if (it != dirents.end()){//find file
    inode_ptr temp= it->second;
    int filetype = temp->get_inode_type();
    if (filetype==1)
      throw invalid_argument ("Invalid file type for mkfile"); 
      //complain()<<"invalid file type for mkfile"<<endl; 
    //return *temp;  
   }//
   inode_ptr newptr (new inode(PLAIN_INODE));
   dirents.insert(pair<string,inode_ptr> (filename, newptr));
   DEBUGF ('i', filename);
   return *newptr;
} 

void directory::print_direc_content(){
   for(auto it = dirents.begin();it!=dirents.end(); it++){
     inode_ptr temp= it->second;
     temp->printInfo();
     cout<<"      "<< it->first << endl;
     //cout<<"test" <<endl; 
     }
}

inode_ptr directory::find_address(const string& name){
  map<string,inode_ptr>::iterator it;
  it = dirents.find(name);
  if (it == dirents.end()){//not find file
     //cout<<"not find file"<<endl;
     return nullptr;
  }
  DEBUGF('i',name);
  return it->second;
}

void inode_state::set_root(inode_ptr& a){
   root= a;
   DEBUGF ('i', "root =" <<root);
}

void inode_state::set_cwd(inode_ptr& b){
  cwd = b;
  DEBUGF ('i', "cwd =" <<cwd);
}

void inode_state::set_parent(inode_ptr& c){
  parent = c;
  DEBUGF ('i', "parent=" <<parent);
}

void inode_state::set_prompt(const string& str ){
  prompt = str;
  DEBUGF ('i', str);
}

inode_ptr inode_state::get_root(){
  DEBUGF ('i', "root =" <<root); 
  return root;
}

inode_ptr inode_state::get_parent(){
  DEBUGF ('i', "parent=" <<parent); 
  return parent;   
}

inode_ptr inode_state::get_cwd(){
   DEBUGF ('i', "cwd =" <<cwd);
   return cwd;
}

string& inode_state::get_prompt(){
  return prompt;
  DEBUGF ('i',"prompt = \"" << prompt << "\"");
}

inode_state::inode_state() {
   DEBUGF ('i', "root = " << root << ", cwd = " << cwd
          << ", prompt = \"" << prompt << "\"");
}

ostream& operator<< (ostream& out, const inode_state& state) {
   out << "inode_state: root = " << state.root
       << ", cwd = " << state.cwd;
   return out;
}

