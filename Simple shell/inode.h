// $Id: inode.h,v 1.13 2014-06-12 18:10:25-07 - - $

#ifndef __INODE_H__
#define __INODE_H__

#include <exception>
#include <iostream>
#include <memory>
#include <map>
#include <vector>
using namespace std;

#include "util.h"

//
// inode_t -
//    An inode is either a directory or a plain file.
//

enum inode_t {PLAIN_INODE, DIR_INODE};
class inode;
class file_base;
class plain_file;
class directory;
using inode_ptr = shared_ptr<inode>;
using file_base_ptr = shared_ptr<file_base>;
using plain_file_ptr = shared_ptr<plain_file>;
using directory_ptr = shared_ptr<directory>;

//
// inode_state -
//    A small convenient class to maintain the state of the simulated
//    process:  the root (/), the current directory (.), and the
//    prompt.
//

class inode_state {
   friend class inode;
   friend ostream& operator<< (ostream& out, const inode_state&);
   private:
      inode_state (const inode_state&) = delete; // copy ctor
      inode_state& operator= (const inode_state&) = delete; // op=
      inode_ptr root {nullptr};
      inode_ptr parent{nullptr};
      inode_ptr cwd {nullptr};
      string prompt {"% "};
   public:
      inode_state();
      inode_state(inode_ptr& a, inode_ptr& b,inode_ptr& c);
      void set_root(inode_ptr& a );
      void set_cwd(inode_ptr& b);
      void set_parent(inode_ptr& c);
      void set_prompt(const string& str);
      inode_ptr get_root();
      inode_ptr get_parent();
      inode_ptr get_cwd();
      string& get_prompt();
     
};


//
// class inode -
//
// inode ctor -
//    Create a new inode of the given type.
// get_inode_nr -
//    Retrieves the serial number of the inode.  Inode numbers are
//    allocated in sequence by small integer.
// size -
//    Returns the size of an inode.  For a directory, this is the
//    number of dirents.  For a text file, the number of characters
//    when printed (the sum of the lengths of each word, plus the
//    number of words.
//    

class inode {
   friend class inode_state;
   private:
      static int next_inode_nr;
      int inode_nr;
      inode_t type;
      file_base_ptr contents;
   public:
      
      inode (inode_t init_type);
      
      int get_inode_nr() const;
      int get_inode_type();
      file_base_ptr& get_file_ptr();
      void printInfo();
      void print_direc_info();
      void print_direc_info(const string& str);
      void recur_print_direc();
      int get_inode_size();
      void push_dot(const string& str,inode_ptr& inodeptr);
      //remove a single plain file or empty direc file
      void pop_node(const string& str);
      void pop_direc_node();
      void recur_pop_direc();
      //according to string name find inode_ptr at current directry 
      inode_ptr find_inode_addr(const string& str);
      //according to pathname, find target inode_ptr      
      inode_ptr find_inode_addr(const wordvec& path,
                                   inode_ptr& cwdptr);
       //find a node name from its parent directory map
      string find_inode_name(inode_ptr& inodeptr);
       //find parent inode address
      inode_ptr find_parent_inodeptr();
      //find plain_file_ptr
      plain_file_ptr get_plainfile_ptr();
      //find directory_ptr
      directory_ptr get_directory_ptr();
      //const string& find_inode_name(inode_ptr& inodeptr);
};

//
// class file_base -
//
// Just a base class at which an inode can point.  No data or
// functions.  Makes the synthesized members useable only from
// the derived classes.
//

class file_base {
   protected:
      file_base () = default;
      file_base (const file_base&) = default;
      file_base (file_base&&) = default;
      file_base& operator= (const file_base&) = default;
      file_base& operator= (file_base&&) = default;
      virtual ~file_base () = default;
      virtual size_t size() const = 0;
   public:
      friend plain_file_ptr plain_file_ptr_of (file_base_ptr);
      friend directory_ptr directory_ptr_of (file_base_ptr);
};


//
// class plain_file -
//
// Used to hold data.
// synthesized default ctor -
//    Default vector<string> is a an empty vector.
// readfile -
//    Returns a copy of the contents of the wordvec in the file.
//    Throws an yshell_exn for a directory.
// writefile -
//    Replaces the contents of a file with new contents.
//    Throws an yshell_exn for a directory.
//

class plain_file: public file_base {
   private:
      wordvec data;
   public:
      size_t size() const override;
      const wordvec& readfile() const;
      void writefile (const wordvec& newdata);
      void remove_file();
 };

//
// class directory -
//
// Used to map filenames onto inode pointers.
// default ctor -
//    Creates a new map with keys "." and "..".
// remove -
//    Removes the file or subdirectory from the current inode.
//    Throws an yshell_exn if this is not a directory, the file
//    does not exist, or the subdirectory is not empty.
//    Here empty means the only entries are dot (.) and dotdot (..).
// mkdir -
//    Creates a new directory under the current directory and 
//    immediately adds the directories dot (.) and dotdot (..) to it.
//    Note that the parent (..) of / is / itself.  It is an error
//    if the entry already exists.
// mkfile -
//    Create a new empty text file with the given name.  Error if
//    a dirent with that name exists.

class directory: public file_base {
   public:
      map<string,inode_ptr> dirents;
   
      size_t size() const override;
      void remove (const string& filename);
      inode& mkdir (const string& dirname);
      inode& mkfile (const string& filename);
      void push_map(const string& name, inode_ptr& inodeptr);
      void print_direc_content();
      inode_ptr find_address(const string& name);
};

#endif

