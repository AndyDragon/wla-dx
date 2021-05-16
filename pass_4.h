
#ifndef _PASS_4_H
#define _PASS_4_H

int pass_4(void);
int mem_insert(unsigned char x);
int mem_insert_padding(void);
int mem_insert_absolute(int add, unsigned char x);
int export_definitions(FILE *final_ptr);
int export_source_file_names(FILE *final_ptr);
int find_label(char *str, struct section_def *s, struct label_def **out);
int show_project_information_library(void);
int show_project_information_object(void);
int write_library_file(void);
int write_object_file(void);

#ifdef W65816
int get_snes_cpu_bank(struct label_def *l);
#endif

#endif
