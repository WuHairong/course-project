// $Id: commands.cpp,v 1.11 2014-06-11 13:49:31-07 - - $
#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <utility>

#include "commands.h"
#include "debug.h"

using namespace std;


commands::commands(): map ({
   {"cat"   , fn_cat   },
   {"cd"    , fn_cd    },
   {"echo"  , fn_echo  },
   {"exit"  , fn_exit  },
   {"ls"    , fn_ls    },
   {"lsr"   , fn_lsr   },
   {"make"  , fn_make  },
   {"mkdir" , fn_mkdir },
   {"prompt", fn_prompt},
   {"pwd"   , fn_pwd   },
   {"rm"    , fn_rm    },
   {"rmr"   , fn_rmr   },
}){}



command_fn commands::at (const string& cmd) {
   // Note: value_type is pair<const key_type, mapped_type>
   // So: iterator->first is key_type (string)
   // So: iterator->second is mapped_type (command_fn)
   command_map::const_iterator result = map.find (cmd);
   if (result == map.end()) {
      throw yshell_exn (cmd + ": no such function");
   }
   return result->second;
}



wordvec string_to_wordvec(const string path){
   string pathname = path;  
   size_t found =pathname.find_first_of("/");
   if(found ==0)//check start with /
      pathname.erase(pathname.begin());
   wordvec temp=split(pathname, "/");
   //for(auto it:temp)
   //  cout<<it<< "   ";
   //cout<<"\n";
   return temp; 

}

void fn_cat (inode_state& state, const wordvec& words){
  if(words.size()==1){
    throw yshell_exn ("no specific file for cat");
   }
   wordvec cat_file=words;
   cat_file.erase(cat_file.begin());
  
  inode_ptr inodeptr=nullptr;
  string filename ="";
  inode_ptr direcnode= nullptr;
  inode_ptr targetnode=nullptr;
  inode_ptr workNode = nullptr;
  wordvec pathname;//path for plain file
  wordvec pathnameapp;//path for direc file
  int type = 100;//hold inode type
  plain_file_ptr fptr=nullptr;//whose content is printed out
  //words[1];
  size_t index =0;
  size_t j=0;//for loop 
    //filename.find_last_of("/");
  for(size_t i=0; i<cat_file.size(); ++i){
    filename=cat_file[i];
    index = filename.find_last_of("/");  
    if(index ==(filename.size()-1))//filename end with "/"
       throw yshell_exn ("a directory file name");
    index =filename.find_first_of("/");
    if(index==0) {inodeptr = state.get_root();}
    else {inodeptr =state.get_cwd();}
    pathname =string_to_wordvec(filename);//plain file 
    pathnameapp = pathname;//direc file path
    j=0;       
    for(;j<pathname.size()-1;++j){//path exist
     pathname[j].append("/");
     pathnameapp[j].append("/");
     }
    pathnameapp[j].append("/");
    direcnode = 
       inodeptr->find_inode_addr(pathnameapp,inodeptr);
    targetnode = 
       inodeptr->find_inode_addr(pathname,inodeptr);
    if(direcnode == nullptr && targetnode==nullptr)
       throw yshell_exn ("No such file");     
    workNode=nullptr;
    if(direcnode != nullptr)
        workNode = direcnode;
    else if (targetnode != nullptr)
        workNode = targetnode;
    type = workNode->get_inode_type();
    if(type ==1)
       throw yshell_exn ("directory file, invalid type for cat");      
    if(type==0){
       fptr=workNode->get_plainfile_ptr();
       fptr->readfile();
       cout<<' '<<endl;
      }
  }
 
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_cd (inode_state& state, const wordvec& words){
   if(words.size()>2){
     throw yshell_exn ("too many operand");
     //cout<<"too many operand"<<endl;
     //return;
   }
   inode_ptr filenode=nullptr;
   inode_ptr direcnode = nullptr;
   if(words.size()==1){//cd root
      filenode=state.get_root();
      state.set_cwd(filenode);
      state.set_parent(filenode);
      return;
     }
   string direcname =words[1];
   wordvec pathname =string_to_wordvec(words[1]);
   wordvec pathnameapp = pathname;//path for direc file
   
   if(direcname.compare("..")==0){//cwd=parent
      //cout<<"test"<<endl;
      filenode = state.get_parent();
      state.set_cwd(filenode);
      inode_ptr parent=filenode->find_inode_addr("..");
      state.set_parent(parent);
      return;
      }
   if(direcname.compare("/")==0){//cwd=root
      filenode=state.get_root();
      state.set_cwd(filenode);
      state.set_parent(filenode);
      return;
     }   
    //set inodeptr to working directory
    size_t index = direcname.find_first_of("/");
    inode_ptr inodeptr=nullptr;
    if(index==0)
       inodeptr = state.get_root();
    else
       inodeptr = state.get_cwd();
    size_t i=0;  
    for(;i<pathname.size()-1;++i){//path exist
          pathname[i].append("/");
          pathnameapp[i].append("/");
         }
    pathnameapp[i].append("/");
    direcnode = 
    inodeptr->find_inode_addr(pathnameapp,inodeptr);
    filenode=inodeptr->find_inode_addr(pathname,inodeptr);
    if(direcnode == nullptr && filenode==nullptr){//direc name
      throw yshell_exn ("Pathname doesn't exist or no such file");
      //cout<<"Pathname doesn't exist or no such file"<<endl;
      //return;
    } 
    inode_ptr workNode=nullptr;
    if(direcnode != nullptr)
      workNode = direcnode;
    else if (filenode != nullptr)
      workNode = filenode;
    int type = workNode->get_inode_type();
    if(type ==0){
       throw yshell_exn("a plain file");
      //cout<<"cd:"<<direcname<<":";
      //cout<<"plain file"<<endl;
      //return;
     }
    if(type ==1){
      state.set_cwd(workNode);
      inode_ptr parent=workNode->find_inode_addr("..");
      state.set_parent(parent);
      }
    
   
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_echo (inode_state& state, const wordvec& words){
   //wordvec content = words;
   for(auto it= words.begin()+1;it !=words.end();++it )
     cout << *it << ' ';
  
   cout<<' '<<endl;
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_exit (inode_state& state, const wordvec& words){
   wordvec exit_state = words;
   if(exit_state.size()==1)
      exit_status::set(0);
   else{
      string state = exit_state[1];  
      bool test=false;
      for(auto it=state.begin(); it!=state.end();++it){
         test= isdigit(*it);
         if(!test)
            break;
      }
     // cout<<test<<endl;
      if(test){
         int i = atoi(state.c_str());
         exit_status::set(i);
       }  
      else
         exit_status::set(127);   

    }
   DEBUGF ('c', state);
   DEBUGF ('c', words);
   throw ysh_exit_exn();
}

void fn_ls (inode_state& state, const wordvec& words){
   //for(auto it: words)
   //  cout << it<< endl;
   inode_ptr inodeptr=nullptr;
  // inode_ptr root = state.get_root();
  // string name="";
   //inode_ptr currentNode = state.get_cwd(); 
   if(words.size()==1){//print cwd content
      inodeptr=state.get_cwd();
      inodeptr->print_direc_info();
      return;
    }
    string filename = words[1];
    if(filename.compare(".")==0  ||
       filename.compare("./")==0 ||
       filename.compare("./*")==0){//print cwd direc
       inodeptr=state.get_cwd();
       inodeptr->print_direc_info(".");   
       return;
     }
    if(filename.compare("/")==0){//print root direc
       inodeptr =state.get_root();
       inodeptr->print_direc_info();
       return;
     }
    else if(filename.compare("..")==0){//show parent dir
       inodeptr =state.get_parent();
       inodeptr->print_direc_info();
       return;
     }
   //set inodeptr to working directory
   size_t index = filename.find_first_of("/");
    if (index==0){
      //start from root
      inodeptr = state.get_root();
     }
    else{
      //start from cwd
      inodeptr =state.get_cwd();
      }
   
      
   wordvec pathname =string_to_wordvec(words[1]);//path for plain file
   wordvec pathnameapp = pathname;//path for direc file
   size_t i=0;     
   for(;i<pathname.size()-1;++i){//path exist
      pathname[i].append("/");
      pathnameapp[i].append("/");
    }
   pathnameapp[i].append("/");
    inode_ptr direcnode = 
    inodeptr->find_inode_addr(pathnameapp,inodeptr);
    inode_ptr targetnode = 
     inodeptr->find_inode_addr(pathname,inodeptr); 
    if(direcnode == nullptr && targetnode==nullptr){//direc name
      throw yshell_exn ("No such file or directory");
      //cout<<"No such file or directory"<<endl;
      //return;
    }
   inode_ptr workNode=nullptr;
   if(direcnode != nullptr)
      workNode = direcnode;
   else if (targetnode != nullptr)
      workNode = targetnode;
   int type = workNode->get_inode_type();
    if(type ==0){
      cout<<words[1]<<endl;  
      return;
      }
    if(type==1){
      workNode->print_direc_info();
      
       }
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_lsr (inode_state& state, const wordvec& words){
   
      
   inode_ptr inodeptr=nullptr;
   
   if(words.size()==1){//print cwd content
      inodeptr =state.get_cwd();
      inodeptr->recur_print_direc();
      return;
     }
   wordvec lsr_file = words;//operand for lsr  
   lsr_file.erase(lsr_file.begin());//remove lsr
   string filename="";//hold path and file name
   size_t index=0;//check form root or cwd
   size_t j=0;//for loop
   wordvec pathname, pathnameapp;//path for node
   inode_ptr direcnode=nullptr;
   inode_ptr targetnode=nullptr;
   inode_ptr workNode=nullptr;
   int type = 100;
   for(size_t i=0;i<lsr_file.size(); ++i){ 
     filename = lsr_file[i];
     if(filename.compare(".")==0  ||
       filename.compare("./")==0 ||
       filename.compare("./*")==0){//print cwd direc
       inodeptr=state.get_cwd();
       inodeptr->recur_print_direc();
       return;
        }
     if(filename.compare("/")==0){//print root direc
        inodeptr =state.get_root();
        inodeptr->recur_print_direc();
        return;
         }
     else if(filename.compare("..")==0){//show parent dir
         inodeptr =state.get_parent();
         inodeptr->recur_print_direc();
         return;
        }
   //set inodeptr to working directory
     index = filename.find_first_of("/");
     if(index==0) {inodeptr = state.get_root();}
     else {inodeptr =state.get_cwd();}
     pathname =string_to_wordvec(filename);//path for plain file
     pathnameapp = pathname;//path for direc file
     j=0;     
     for(;j<pathname.size()-1;++j){//path exist
       pathname[j].append("/");
       pathnameapp[j].append("/");
      }
     pathnameapp[j].append("/");
     direcnode = 
        inodeptr->find_inode_addr(pathnameapp,inodeptr);
     targetnode = 
        inodeptr->find_inode_addr(pathname,inodeptr); 
     if(direcnode == nullptr && targetnode==nullptr)//direc name
        throw yshell_exn("No such file or directory");    
     workNode=nullptr;
     if(direcnode != nullptr)
       workNode = direcnode;
     else if (targetnode != nullptr)
       workNode = targetnode;
     type = workNode->get_inode_type();
     if(type ==0){
        cout<<words[1]<<endl;  
        return;
        }
     if(type==1)
        workNode->recur_print_direc();      
  }
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}


void fn_make (inode_state& state, const wordvec& words){
   if(words.size()==1){
     throw yshell_exn ("No specific file to make");
    }
   string filename =words[1];
   size_t index =filename.find_last_of("/");
   if(index==(filename.size()-1) )
     throw yshell_exn ("Can't use directory name for make");
   inode_ptr inodeptr=nullptr;
   index =filename.find_first_of("/");
   //path start from root
   if(index==0) {inodeptr = state.get_root();}
   //path start from cwd
   else {inodeptr =state.get_cwd();}
   //process path
   wordvec pathname =string_to_wordvec(words[1]);
   
   string lastname = pathname.back();
   string lastnameapp=lastname;
   lastnameapp.append("/");
   inode_ptr direcnode=nullptr;
   inode_ptr filenode =nullptr;
   inode_ptr parentnode=nullptr;
   if(pathname.size()==1){
     filenode =
          inodeptr->find_inode_addr(lastname);
     direcnode =
          inodeptr->find_inode_addr(lastnameapp);
   }
   else if(pathname.size()>1){
     pathname.pop_back();
     for(size_t i=0;i<pathname.size();++i){//path exist
        pathname[i].append("/");   
       }
     parentnode = //parent of target file 
     inodeptr->find_inode_addr(pathname,inodeptr);  
     if(parentnode==nullptr){
       throw yshell_exn("Path doesn't exist");
       }
     filenode =parentnode->find_inode_addr(lastname);
     direcnode=parentnode->find_inode_addr(lastnameapp);
    }
   if(parentnode ==nullptr)
     parentnode=inodeptr;  
   if(direcnode !=nullptr)
    throw yshell_exn ("Directory file"); 
   
   //process file content
   wordvec filecont=words;
   filecont.erase(filecont.begin());//erase make
   filecont.erase(filecont.begin());//erase filename
   if(filenode!=nullptr){ //plain file exist   
     plain_file_ptr ppptr =filenode->get_plainfile_ptr();
     ppptr->writefile(filecont);
     return;
    }
    else if(filenode==nullptr){//not found
     //inode_ptr newnode (new inode(PLAIN_INODE));
     inode_ptr newnode = 
        make_shared<inode>(inode(PLAIN_INODE));
     plain_file_ptr pptr=newnode->get_plainfile_ptr();
     pptr->writefile(filecont);
     parentnode->push_dot(lastname, newnode);
     }
 
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_mkdir (inode_state& state, const wordvec& words){
  if(words.size()==1){
     throw yshell_exn("No specific file name");
    }   
  inode_ptr inodeptr=nullptr;
  string filename = words[1];
  size_t index =filename.find_first_of("/");
  if(index==0) {inodeptr = state.get_root();}
  else {inodeptr =state.get_cwd();}
   //process path
  wordvec pathname =string_to_wordvec(words[1]);//plain file path  
  string lastname = pathname.back();
  string lastnameapp=lastname;
  lastnameapp.append("/");
  inode_ptr direcnode=nullptr;
  inode_ptr filenode =nullptr;
  inode_ptr parentnode=nullptr;
  if(pathname.size()==1){
     filenode =
          inodeptr->find_inode_addr(lastname);
     direcnode =
          inodeptr->find_inode_addr(lastnameapp);
     }
  else if(pathname.size()>1){
      pathname.pop_back();
      for(size_t i=0;i<pathname.size();++i){//path exist
         pathname[i].append("/");   
        }
      parentnode = //parent of target file 
        inodeptr->find_inode_addr(pathname,inodeptr);  
      if(parentnode==nullptr){
        throw yshell_exn("Path doesn't exist");
        }
      filenode =parentnode->find_inode_addr(lastname);
      direcnode=parentnode->find_inode_addr(lastnameapp);
    }
   if(parentnode ==nullptr)
      parentnode=inodeptr;  
   if(direcnode !=nullptr)
       throw yshell_exn ("Directory file exist");
   if(filenode!= nullptr)
       throw yshell_exn ("Plain file exist");
   //inode_ptr newnode (new inode(DIR_INODE));
   inode_ptr newnode =
         make_shared<inode>(inode(DIR_INODE));
   newnode->push_dot(".", newnode);
   newnode->push_dot("..", parentnode);
   parentnode->push_dot(lastnameapp, newnode);
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_prompt (inode_state& state, const wordvec& words){
   string prompt;
   for(size_t it=1; it<words.size();++it){     
     prompt.append(words[it]);
     prompt.append(" ");
    }
   prompt.pop_back();
   state.set_prompt(prompt);
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_pwd (inode_state& state, const wordvec& words){
   if(words.size()!=1)
     return;
   inode_ptr cwdnode = state.get_cwd();
   inode_ptr root    = state.get_root();
   inode_ptr parentptr = nullptr;
   string name="";
   string path="";
   for(;;){
     parentptr = cwdnode->find_parent_inodeptr();
      if(cwdnode==root){
        name = "/";
        path.insert(0, name);
        break;
       }
      if(parentptr == root){
        name = parentptr->find_inode_name(cwdnode);
        path.insert(0, name);
        break;
       }
      name = parentptr->find_inode_name(cwdnode);
      path.insert(0, name);
      cwdnode = parentptr;
   }
   path.insert(0, "/");
   size_t found=path.find_last_of("/");
   path.erase(found);
   cout<<path;
   cout<<'\n';
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_rm (inode_state& state, const wordvec& words){
   if(words.size()==1){
     throw yshell_exn("No specific file for rm");
   }
   inode_ptr inodeptr=nullptr;
   string filename =words[1];
   size_t index =filename.find_first_of("/");
   if(index==0) {inodeptr = state.get_root();}
   else {inodeptr =state.get_cwd();}
   wordvec pathname =string_to_wordvec(words[1]);//plain file 

   string lastname = pathname.back();
   string lastnameapp=lastname;
   lastnameapp.append("/");
   inode_ptr direcnode=nullptr;
   inode_ptr filenode =nullptr;
   inode_ptr parentnode=nullptr;
   if(pathname.size()==1){
     filenode =
          inodeptr->find_inode_addr(lastname);
     direcnode =
          inodeptr->find_inode_addr(lastnameapp);
   }
   else if(pathname.size()>1){
      //remove the last name at the path
      pathname.pop_back();// 
      for(size_t i=0;i<pathname.size();++i){//path exist
         pathname[i].append("/");   
      }
     parentnode = //parent of target file 
       inodeptr->find_inode_addr(pathname,inodeptr);
     if(parentnode==nullptr){
         throw yshell_exn("Path doesn't exist");
       }
     filenode =parentnode->find_inode_addr(lastname);
     direcnode=parentnode->find_inode_addr(lastnameapp);
     }
  // inode_ptr targetnode = 
  //   inodeptr->find_inode_addr(pathname,inodeptr);
   if(direcnode == nullptr && filenode==nullptr){
     throw yshell_exn("No such file");
   }   
   if(parentnode==nullptr)
     parentnode = inodeptr;
   
   inode_ptr workNode=nullptr;
  if(direcnode != nullptr)
      workNode = direcnode;
  else if (filenode != nullptr)
      workNode = filenode;
  int type = workNode->get_inode_type();
  int size = workNode->get_inode_size();
  if(type ==1 && size >2)//direc file not empty
     throw yshell_exn("Not empty directory"); 
  else if(type==1 && size <= 2)
     parentnode->pop_node(lastnameapp);        
  else if(type==0)//plain file
     parentnode->pop_node(lastname);
     
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

void fn_rmr (inode_state& state, const wordvec& words){
   inode_ptr targetnode = nullptr;//direc node 
   
   if(words.size()==1){
     targetnode =state.get_cwd();
     targetnode->recur_pop_direc();
     return;
   }
   inode_ptr inodeptr=nullptr;
   string filename =words[1];
   if(filename.compare(".")==0  ||
      filename.compare("./")==0 ||
      filename.compare("./*")==0)   
      targetnode =state.get_cwd();
   if(filename.compare("/")==0)    
      targetnode =state.get_root();
   if(filename.compare("..")==0)
      targetnode =state.get_parent();
   //process path
   size_t index =filename.find_first_of("/");
   if(index==0) {inodeptr = state.get_root();}
   else {inodeptr =state.get_cwd();}
   wordvec pathname =string_to_wordvec(words[1]);
   wordvec pathnameapp = pathname;
   size_t i=0;     
   for(;i<pathname.size()-1;++i){//path exist
      pathname[i].append("/");
      pathnameapp[i].append("/");
    }
   pathnameapp[i].append("/");
   inode_ptr direcnode = 
      inodeptr->find_inode_addr(pathnameapp,inodeptr);
   inode_ptr filenode = 
      inodeptr->find_inode_addr(pathname,inodeptr);   
   if(direcnode == nullptr && filenode==nullptr)//direc name
      throw yshell_exn ("No such file or directory");   
   inode_ptr workNode=nullptr;
   if(direcnode != nullptr)
      workNode = direcnode;
   else if (targetnode != nullptr)
      workNode = targetnode;
   int type = workNode->get_inode_type();
   if(type ==0)
     throw yshell_exn("Plain file");
   if(type==1)
     targetnode=workNode;
   targetnode->recur_pop_direc();   
   
   DEBUGF ('c', state);
   DEBUGF ('c', words);
}

int exit_status_message() {
   int exit_status = exit_status::get();
   cout << execname() << ": exit(" << exit_status << ")" << endl;
   return exit_status;
}

