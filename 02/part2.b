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

append_if_not_exist(buf, len, item) {
    auto i; i = 0; while (i < *len) {
        if (buf[i] == item) return;
        i += 1;
    }
    buf[*len] = item;
    *len = *len + 1;
}

print_buf[32];
find_dups(lhs, rhs, len, step, result, result_len) {
    extrn sprintf;

    auto id_min; id_min = str2int(lhs, step);
    auto id_max; id_max = str2int(rhs, step);

    auto i; i = step; while (i < len) {
        auto n; n = str2int(lhs+i, step);
        if (n > id_min) {
            id_min += 1;
            goto break1;
        } else if (n < id_min) {
            goto break1;
        }

        i += step;
    }
break1:

    i = step; while (i < len) {
        auto n; n = str2int(rhs+i, step);
        if (n < id_max) {
            id_max -= 1;
            goto break2;
        } else if (n > id_max) {
            goto break2;
        }

        i += step;
    }
break2:

    while (id_min <= id_max) {
        auto j; j = 0; while (j < len) {
            sprintf(print_buf+j, "%zu", id_min);
            j += step;
        }

        append_if_not_exist(result, result_len, str2int(print_buf, len));

        id_min += 1;
    }
}

append_dups(lhs, rhs, len, result, result_len) {
    find_dups(lhs, rhs, len, 1, result, result_len);
    if (len%2 == 0 & len/2 > 1) find_dups(lhs, rhs, len, 2, result, result_len);
    if (len%3 == 0 & len/3 > 1) find_dups(lhs, rhs, len, 3, result, result_len);
    if (len%4 == 0 & len/4 > 1) find_dups(lhs, rhs, len, 4, result, result_len);
    if (len%5 == 0 & len/5 > 1) find_dups(lhs, rhs, len, 5, result, result_len);
}

duplicates[1024];
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

        auto dups_count; dups_count = 0;
        if (lhs_len != rhs_len) {
            if (lhs_len > 1) {
                memcpy(lhs_buf, lhs, lhs_len);
                sprintf(rhs_buf, "%zu", pow(10, rhs_len-1) - 1);
                append_dups(lhs_buf, rhs_buf, lhs_len, duplicates, &dups_count);
            }

            sprintf(lhs_buf, "%zu", pow(10, rhs_len-1));
            memcpy(rhs_buf, rhs, rhs_len);
            append_dups(lhs_buf, rhs_buf, rhs_len, duplicates, &dups_count);
        } else {
            memcpy(lhs_buf, lhs, lhs_len);
            memcpy(rhs_buf, rhs, lhs_len);
            append_dups(lhs_buf, rhs_buf, lhs_len, duplicates, &dups_count);
        }

        printf("duplicates:\n");
        auto i; i = 0; while (i < dups_count) {
            answer += duplicates[i];
            printf("    %zu\n", duplicates[i]);
            i += 1;
        }

        dups_count = 0;

        printf("========================================\n");
        ptr += 1;
    }

    printf("Answer=%zu\n", answer);
}
