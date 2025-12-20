#import "Basic"()(MEMORY_DEBUGGER = false);
#import "File";
Posix :: #import "POSIX";

main :: () {
    //defer report_memory_leaks();
    retval : s32 = 0;
    defer exit(retval);
    
    args := get_command_line_arguments();
    defer free(args.data);

    chunk_size := get_chunk_size();

    // First arg is program name
    // Handle no args just do stdin
    if args.count == 1 {
        buffer := cast(*u8)alloc(chunk_size);
        defer free(buffer);

        success := cat_stdin(Posix.STDIN_FILENO, buffer, chunk_size);
        if !success {
            print_error("Failed to cat from stdin\n");
            retval = 1;
            return;
        }
        return;
    }

    cmds := array_view(args, 1, args.count);

    if cmds.count > 0 {
        file_path := cmds[0];
        buffer := cast(*u8)alloc(chunk_size);
        defer free(buffer);

        for i: 0..cmds.count-1 {
            file_path := cmds[i];
            if file_path == "--help" || file_path == "-h" || file_path == "help" {
                show_help();
                return;
            }
            if file_path == "-" {
                if !cat_stdin(Posix.STDIN_FILENO, buffer, chunk_size) {
                    print_error("Failed to cat from stdin\n");
                    retval = 1;
                    return;
                }
            } else {
                success := cat_one(file_path, buffer, chunk_size);
                if !success {
                    print_error("Failed to cat file: %\n", file_path);
                    retval = 1;
                    return;
                }
            }
        }   
    }
}

get_chunk_size :: () -> s64 {
    page := cast(s64)Posix.getpagesize();
    if page <= 0 page = 4096;

    target: s64 = 64 * 1024;
    chunk := ((target + page - 1) / page) * page;
    return chunk;
}

cat_stdin :: (fd: s32, buffer: *u8, chunk_size: s64) -> bool {
    while true {
        n := Posix.read(fd, buffer, cast(u64)(chunk_size));
        if n == 0 return true; // EOF 
        if n < 0 return false; // Error

        wrote: s64;
        while wrote < n {
            w := Posix.write(Posix.STDOUT_FILENO, buffer + wrote, cast(u64)(n - wrote));
            if w > 0 {
                wrote += w;
                continue;
            }
            // w <= 0 => error (or weird case)
            // TODO: if Posix.errno == Posix.EINTR continue;

            print_error("\nERROR: ");
            print("Write failed\n");
            return false;
        }
    }
}

cat_one :: (file_path: string, buffer: *u8, chunk_size: s64) -> bool {

    file, success := file_open(file_path, log_errors=false);
    if !success {
        print_error("\nERROR: ");
        print("Could not open file %\n", file_path);
        return false;
    }
    defer file_close(*file);

    while true {
        success, n := file_read(file, buffer, chunk_size);
        if !success {
            print_error("\nERROR: ");
            print("Error reading from file %\n", file_path);
            return false;
        } 
        if n == 0 break; // EOF

        wrote: s64;
        while wrote < n {
            w := Posix.write(Posix.STDOUT_FILENO, buffer + wrote, cast(u64)(n - wrote));
            if w > 0 {
                wrote += w;
                continue;
            }
            // w <= 0 => error (or weird case)
            // TODO: if Posix.errno == Posix.EINTR continue;

            print_error("\nERROR: ");
            print("Write failed\n");
            return false;
        }
    }

    return true;
}

show_help :: () {
    print("\n==================================\n");
    print("jcat - A cat clone written in Jai\n\n");
    print("Usage: jcat <file1> [file2 ...]\n");
    print("==================================\n\n");
}

print_error :: (format_string: string, args: .. Any) {
    write_string("\u001b[31m");
    print(format_string, .. args);
    write_string("\u001b[0m");
}