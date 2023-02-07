// for RTLD_NEXT
#define _GNU_SOURCE

// dlsym
#include <dlfcn.h>

#include <stdlib.h>

bool (*fuzz_nalloc_fail) (size_t)= NULL;

static void* (*fuzz_nalloc_orig_realloc)(void*, size_t)=NULL;
static void* (*fuzz_nalloc_orig_malloc)(size_t)=NULL;
static void* (*fuzz_nalloc_orig_calloc)(size_t, size_t)=NULL;

void *calloc(size_t nmemb, size_t size) {
    if (fuzz_nalloc_orig_calloc == NULL) {
        fuzz_nalloc_orig_calloc = dlsym(RTLD_NEXT, "calloc");
    }
    if (fuzz_nalloc_fail && fuzz_nalloc_fail(size)) {
        return NULL;
    }
    return fuzz_nalloc_orig_calloc(nmemb, size);
}

void *malloc(size_t size) {
    if (fuzz_nalloc_orig_malloc == NULL) {
        fuzz_nalloc_orig_malloc = dlsym(RTLD_NEXT, "malloc");
    }
    if (fuzz_nalloc_fail && fuzz_nalloc_fail(size)) {
        return NULL;
    }
    return fuzz_nalloc_orig_malloc(size);
}

void *realloc(void *ptr, size_t size) {
    if (fuzz_nalloc_orig_realloc == NULL) {
        fuzz_nalloc_orig_realloc = dlsym(RTLD_NEXT, "realloc");
    }
    if (fuzz_nalloc_fail && fuzz_nalloc_fail(size)) {
        return NULL;
    }
    return fuzz_nalloc_orig_realloc(ptr, size);
}
