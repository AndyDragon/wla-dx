
#ifndef _PARSE_H
#define _PARSE_H

int input_number(void);
int input_next_string(void);
int get_next_plain_string(void);
int get_next_token(void);
int skip_next_token(void);
int compare_next_token(char *token);
int compare_and_skip_next_symbol(char symbol);
int expand_macro_arguments(char *in);
int expand_variables_inside_string(char *label, int max_size, int *length);
int is_string_ending_with(char *s, char *e);
int strcaselesscmpn(char *s1, char *s2, int length);
int process_special_labels(char *label);
int process_string_for_special_characters(char *label, int *string_size);
int parse_function(char *in, char *name, int *found_function, int *parsed_chars);

#endif
