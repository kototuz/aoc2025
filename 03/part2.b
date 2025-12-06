assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

read_entire_file(file_name, res_size) {
    extrn fopen, fclose, fseek, rewind, ftell, malloc, fread, printf, feof;
    auto file, file_size, i, buf;

    file = fopen(file_name, "r");
    fseek(file, 0, 2);
    file_size = ftell(file) + 1;
    rewind(file);

    buf = malloc(file_size);
    fread(buf, file_size, file_size, file);
    fclose(file);

    *(buf+file_size) = 0x0;
    if (res_size != 0) {
        *res_size = file_size - 1;
    }

    return(buf);
}

next_line(line, res_len) {
    auto ptr, len; ptr = *line + *res_len;

    if (char(ptr, 0) == '\n') {
        ptr += 1;
        if (char(ptr, 0) == '\0') return(0);
    }

    len = 0; while (char(ptr, len) != '\n') len += 1;

    *line = ptr;
    *res_len = len;
    return(1);
}

find_max_digit(begin, end) {
    auto res; res = begin;
    while (begin != end) {
        if (char(begin, 0) > char(res, 0)) {
            res = begin;
        }
        begin += 1;
    }

    return(res);
}

main() {
    extrn abort;
    auto input; input = read_entire_file("input.txt");

    auto answer; answer = 0;
    auto line, line_len; line = input; line_len = 0;
    while (next_line(&line, &line_len)) {
        printf("%.*s\n", line_len, line);

        auto n; n = 0;
        auto begin; begin = line;
        auto end; end = line+line_len-11;
        auto len; len = line_len;
        auto i; i = 0; while (i < 12) {
            auto max_digit_ptr; max_digit_ptr = find_max_digit(begin, end);
            n = 10*n + (char(max_digit_ptr, 0) - '0');
            begin = max_digit_ptr + 1;
            end += 1;
            i += 1;
        }

        answer += n;

        printf("========================================\n");
    }

    printf("Answer=%zu\n", answer);
}
