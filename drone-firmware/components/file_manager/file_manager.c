#include <stdio.h>

#include "file_manager.h"
#include "storage.h"
#include"param.h"

static FILE* current_file = NULL;

//Opens a file (deletes previous contents)
void open_new_file(const char *filepath) { //TODO this function isn't very modular
    if (current_file) {
        fclose(current_file);
    }
    current_file = fopen(filepath, "wb");
    if (!current_file) {
        //printf("Failed to open %s\n", filepath); TODO fail out
        return;
    }
}

void write_current_file(const uint8_t *buffer, size_t nbyte) //TODO this function isn't very modular
{
    if (!current_file) {
        //("Failed to open %s\n", path); TODO
        return;
    }
    fwrite(buffer, 1, nbyte, current_file);
    fflush(current_file);
}

void close_current_file(void) { //TODO this function isn't very modular
    if (current_file) {
        fclose(current_file);
        current_file = NULL;
    }
}