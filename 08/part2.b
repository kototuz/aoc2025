WORD_SIZE;

BOXES; BOXES_CAP 1000; BOX_COUNT  0;
X 0; Y 1; Z 2; PARENT_IDX 3;
SIZEOF_BOX 4;

PAIRS; PAIRS_CAP 500000; PAIR_COUNT 0;
SIZEOF_PAIR 3;
A_IDX 0; B_IDX 1; DISTANCE 2;



assert(expr, msg) {
    extrn abort;
    if (!expr) {
        printf("ASSERTION FAILED: %s\n", msg);
        abort();
    }
}

read_entire_file(file_name, res_size) {
    extrn fopen, fclose, fseek, rewind, ftell, malloc, memset, fread;
    auto file, file_size, buf;

    file = fopen(file_name, "r");
    fseek(file, 0, 2);
    file_size = ftell(file) + 1;
    rewind(file);

    buf = malloc(file_size);
    memset(buf, 0, file_size);
    fread(buf, file_size, file_size, file);
    fclose(file);

    if (res_size != 0) {
        *res_size = file_size;
    }

    return(buf);
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

push_box(x, y, z, parent_idx) {
    auto new_box;
    assert(BOX_COUNT < BOXES_CAP, "BOXES overflowed");
    BOXES[BOX_COUNT][X] = x;
    BOXES[BOX_COUNT][Y] = y;
    BOXES[BOX_COUNT][Z] = z;
    BOXES[BOX_COUNT][PARENT_IDX] = parent_idx;
    BOX_COUNT += 1;
}

push_pair(box1_idx, box2_idx, distance) {
    auto new_pair;
    assert(PAIR_COUNT < PAIRS_CAP, "PAIRS overflowed");
    PAIRS[PAIR_COUNT][A_IDX] = box1_idx;
    PAIRS[PAIR_COUNT][B_IDX] = box2_idx;
    PAIRS[PAIR_COUNT][DISTANCE] = distance;
    PAIR_COUNT += 1;
}

load_boxes(file_path) {
    extrn free;
    auto data, ptr, x, y, z;
    data = read_entire_file(file_path, 0);
    ptr = data;
    while (char(ptr, 0) != '\0') {
        ptr = str2int(ptr, &x) + 1;
        ptr = str2int(ptr, &y) + 1;
        ptr = str2int(ptr, &z) + 1;
        push_box(x, y, z, BOX_COUNT);
    }
    free(data);
}

make_pairs() {
    extrn ddist3d;
    auto i, j, dist, box_a, box_b;
    i = 0; while (i < BOX_COUNT) {
        box_a = BOXES[i];
        j = i+1; while (j < BOX_COUNT) {
            box_b = BOXES[j];
            dist = ddist3d(box_a[X], box_a[Y], box_a[Z], box_b[X], box_b[Y], box_b[Z]);
            push_pair(i, j, dist);
            j += 1;
        }
        i += 1;
    }
}

struct_array(cap, sizeof_struct_in_words) {
    extrn malloc;
    auto arr, i;

    arr = malloc((1 + sizeof_struct_in_words) * cap * WORD_SIZE);
    i = 0; while (i < cap) {
        arr[i] = &arr[i*sizeof_struct_in_words + cap];
        i += 1;
    }

    return(arr);
}

find_pair_idx_with_min_dist(begin_idx) {
    extrn dless;
    auto res, i;
    res = begin_idx;
    i = begin_idx+1; while (i < PAIR_COUNT) {
        if (dless(PAIRS[i][DISTANCE], PAIRS[res][DISTANCE])) {
            res = i;
        }
        i += 1;
    }
    return(res);
}

remove_pair(idx) PAIRS[idx] = PAIRS[--PAIR_COUNT];

print_pair(p) {
    extrn dprint;
    printf(
        "%-3zu %-3zu %-3zu | %-3zu %-3zu %-3zu | ",
        BOXES[p[A_IDX]][X],
        BOXES[p[A_IDX]][Y],
        BOXES[p[A_IDX]][Z],
        BOXES[p[B_IDX]][X],
        BOXES[p[B_IDX]][Y],
        BOXES[p[B_IDX]][Z]
    );
    dprint(p[DISTANCE]);
    printf("\n");
}

find(bi) {
    if (BOXES[bi][PARENT_IDX] == bi) {
        return(bi);
    }

    return(find(BOXES[bi][PARENT_IDX]));
}

unite(bi1, bi2) {
    auto irep, jrep;

    irep = find(bi1);
    jrep = find(bi2);

    if (irep != jrep) {
        BOXES[irep][PARENT_IDX] = jrep;
        return(1);
    }

    return(0);
}

all_boxes_in_same_circuit() {
    auto i, pi;
    pi = find(0);
    i = 0; while (i < BOX_COUNT) {
        if (find(BOXES[i][PARENT_IDX]) != pi) {
            return(0);
        }
        i += 1;
    }
    return(1);
}

main() {
    extrn dprint, malloc;

    WORD_SIZE = &0[1];

    BOXES = struct_array(BOXES_CAP, SIZEOF_BOX);
    PAIRS = struct_array(PAIRS_CAP, SIZEOF_PAIR);

    load_boxes("input.txt");
    make_pairs();

    auto i, pi, circuit_count;

    circuit_count = BOX_COUNT;
    i = 0; while (i < PAIR_COUNT) {
        pi = find_pair_idx_with_min_dist(i);
        if (unite(PAIRS[pi][A_IDX], PAIRS[pi][B_IDX])) {
            circuit_count -= 1;
            if (circuit_count == 1) {
                print_pair(PAIRS[pi]);
                printf("Answer=%zu\n", BOXES[PAIRS[pi][A_IDX]][X] * BOXES[PAIRS[pi][B_IDX]][X]);
                return;
            }
        }

        remove_pair(pi);
        i += 1;
    }
}
