// $Id: main.cpp,v 1.3 2014-06-11 13:52:31-07 - - $

#include <cstdlib>
#include <iostream>
#include <string>
#include <memory>
#include <vector>
#include <utility>
#include <unistd.h>

using namespace std;

#include "commands.h"
#include "debug.h"
#include "inode.h"
#include "util.h"

//
// scan_options
//    Options analysis:  The only option is -Dflags. 
//

void scan_options (int argc, char** argv) {
   opterr = 0;
   for (;;) {
      int option = getopt (argc, argv, "@:");
      if (option == EOF) break;
      switch (option) {
         case '@':
            debugflags::setflags (optarg);
            break;
         default:
            complain() << "-" << (char) option << ": invalid option"
                       << endl;
            break;
      }
   }
   if (optind < argc) {
      complain() << "operands not permitted" << endl;
   }
}


//
// main -
//    Main program which loops reading commands until end of file.
//

int main (int argc, char** argv) {
   execname (argv[0]);
   cout << boolalpha; // Print false or true instead of 0 or 1.
   cerr << boolalpha;
   cout << argv[0] << " build " << __DATE__ << " " << __TIME__ << endl;
   scan_options (argc, argv);
   bool need_echo = want_echo();
   commands cmdmap;
   string prompt = "%";
   inode_ptr root = 
     make_shared<inode>(inode(DIR_INODE));
   //inode_ptr root(new inode(DIR_INODE));
   
   root->push_dot(".", root);
   root->push_dot("..", root);
   //inode_state state();
   inode_state state(root, root, root);
   state.set_prompt("%");
   try {
      for (;;) {
         try {
   
            // Read a line, break at EOF, and echo print the prompt
            // if one is needed.
            cout << state.get_prompt() << " ";
            string line;
            getline (cin, line);
            if (cin.eof()) {
               if (need_echo) cout << "^D";
               cout << endl;
               //state.set_cwd(root);
               //state.set_parent(root);
               //wordvec wordss;
               //wordss[0]="/";
               //command_fn fn = cmdmap.at("rmr");
               //fn (state, wordss);
               //root=nullptr;
               //state.set_cwd(root);
               //state.set_parent(root);
               //state.set_root(root);
               DEBUGF ('y', "EOF");
               break;
            }
            if(line.size()==0)
               continue;
            if (need_echo) cout << line << endl;
   
            // Split the line into words and lookup the appropriate
            // function.  Complain or call it.
            wordvec words = split (line, " \t");
            string first = words[0];
            if(first.front()=='#')
              continue;   
            DEBUGF ('y', "words = " << words);
            command_fn fn = cmdmap.at(words.at(0));
            fn (state, words);
         }catch (yshell_exn& exn) {
            // If there is a problem discovered in any function, an
            // exn is thrown and printed here.
            complain() << exn.what() << endl;
         }
      }
   } catch (ysh_exit_exn& ) {
      // This catch intentionally left blank.
   }
   //state.set_cwd(root);
   //words.clear();
   //words.push_back("/");
   //command_fn fn = cmdmap.at("rmr");
   
   return exit_status_message();
}

