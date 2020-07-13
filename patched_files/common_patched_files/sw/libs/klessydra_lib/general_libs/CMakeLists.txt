set(SOURCES
    src/Klessydra_En_Int.c
    src/Klessydra_get_coreID.c
    src/Klessydra_get_mhartid.c
    src/klessydra_lock_acquire.c
    src/klessydra_lock_release.c
    src/Klessydra_WFI.c
    src/load_mem.c
	src/performance_counters.c
    src/send_sw_irq.c
    src/sync_barrier.c
    src/sync_barrier_reset.c
    src/sync_barrier_thread_registration.c
    )

set(HEADERS
    inc/functions.h
    inc/klessydra_defs.h
    inc/riscv_test.h
    inc/test_macros.h
    inc/encoding.h
    )

include_directories(inc/)

add_library(kless_libs STATIC ${SOURCES} ${HEADERS})

