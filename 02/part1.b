assert(expr, msg) {
    extrn puts, abort;
    if (!expr) {
        puts(msg);
        abort();
    }
}

read_int(file) {
    extrn fgetc, isdigit;
    auto res, s;

    res = 0;
    while (1) {
        s = fgetc(file);
        if (!isdigit(s)) goto end;
        res = res*10 + (s - '0');
    }

end:
    return(res);
}

str2int(ptr, len) {
    auto n; n = 0;
    auto i; i = 0; while (i < len) {
        n = n*10 + (char(ptr, i) - '0');
        i += 1;
    }

    return(n);
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
        *res_size = file_size;
    }

    return(buf);
}

pow(n, exp) {
    auto i, res; res = n;
    i = 1; while (i++ < exp) res *= n;
    return(res);
}

main() {
    extrn isdigit, sprintf, malloc, memcpy, strlen;
    auto buf; buf = read_entire_file("input.txt");

    auto ptr, lhs, lhs_len, rhs, rhs_len;
    ptr = buf;

    auto lhs_buf; lhs_buf = malloc(32);
    auto rhs_buf; rhs_buf = malloc(32);

    auto answer; answer = 0;
    while (char(ptr, 0) != 0) {
        lhs = ptr;
        while (isdigit(char(ptr, 0))) ptr++;
        lhs_len = ptr - lhs;

        rhs = ++ptr;
        while (isdigit(char(ptr, 0))) ptr++;
        rhs_len = ptr - rhs;

        printf("min=%.*s max=%.*s\n", lhs_len, lhs, rhs_len, rhs);
        assert(rhs_len-lhs_len < 2, "Unexpected difference");

        memcpy(lhs_buf, lhs, lhs_len);
        memcpy(rhs_buf, rhs, rhs_len);

        auto min_id, max_id;
        if (rhs_len-lhs_len > 0) {
            if (lhs_len%2 != 0) {
                sprintf(lhs_buf, "%zu", pow(10, ++lhs_len));
                printf("min -> %.*s\n", lhs_len, lhs_buf);
            } else {
                sprintf(rhs_buf, "%zu", pow(10, --rhs_len) - 1);
                printf("max -> %.*s\n", rhs_len, rhs_buf);
            }
        } else if (lhs_len%2 != 0 & rhs_len%2 != 0) {
            printf("skip.\n");
            goto continue;
        }

        auto seq_len; seq_len = lhs_len / 2;

        auto p1_min; p1_min = str2int(lhs_buf, seq_len);
        auto p1_max; p1_max = str2int(rhs_buf, seq_len);
        printf("p1_min=%zu p1_max=%zu\n", p1_min, p1_max);

        auto p2_min; p2_min = str2int(lhs_buf+seq_len, seq_len);
        auto p2_max; p2_max = str2int(rhs_buf+seq_len, seq_len);
        printf("p2_min=%zu p2_max=%zu\n", p2_min, p2_max);

        auto dup_count; dup_count = p1_max - p1_min + 1;
        auto begin; begin = p1_min;
        if (dup_count == 1) {
            if (p1_min < p2_min | p1_min > p2_max) {
                dup_count -= 1;
            }
        } else {
            if (p1_min < p2_min) {
                begin += 1;
                dup_count -= 1;
            }
            if (p1_max > p2_max) {
                dup_count -= 1;
            }
        }

        auto max_n; max_n = begin+dup_count;
        while (begin < max_n) {
            sprintf(lhs_buf, "%zu%zu", begin, begin);
            answer += str2int(lhs_buf, strlen(lhs_buf));
            begin += 1;
        }

continue:
        printf("========================================\n");
        ptr += 1;
    }

    printf("Answer=%zu\n", answer);
}
