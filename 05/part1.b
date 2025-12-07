assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

str2int(ptr, result) {
    extrn isdigit;
    auto n; n = 0;
    while (1) {
        if (!isdigit(char(ptr, 0))) {
            *result = n;
            return(ptr);
        }

        n = n*10 + (char(ptr, 0) - '0');
        ptr += 1;
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
        *res_size = file_size;
    }

    return(buf);
}

numbers[512];
numbers_count 0;
append(n) {
    assert(numbers_count < 512, "Increase numbers capacity");
    numbers[numbers_count++] = n;
}

is_id_fresh(id) {
    auto i; i = 0; while (i < numbers_count) {
        if (numbers[i] <= id & id <= numbers[i+1])
            return(1);
        i += 2;
    }
    return(0);
}

main() {
    auto input; input = read_entire_file("input.txt");

    auto ptr; ptr = input;
    while (char(ptr, 0) != '\n') {
        auto n;
        ptr = str2int(ptr, &n);
        append(n);
        ptr = str2int(ptr+1, &n);
        append(n);
        ptr += 1;
    }

    ptr += 1;

    auto answer; answer = 0;
    while (char(ptr, 0) != '\0') {
        auto id;
        ptr = str2int(ptr, &id);
        if (is_id_fresh(id)) {
            answer += 1;
        }

        ptr += 1;
    }

    printf("Answer=%zu\n", answer);
}
