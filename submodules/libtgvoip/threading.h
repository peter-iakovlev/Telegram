//
// Created by Grishka on 27.05.16.
//

#ifndef __THREADING_H
#define __THREADING_H

#if defined(_POSIX_THREADS) || defined(_POSIX_VERSION) || defined(__unix__) || defined(__unix) || (defined(__APPLE__) && defined(__MACH__))

#include <pthread.h>

typedef pthread_t tgvoip_thread_t;
typedef pthread_mutex_t tgvoip_mutex_t;
typedef pthread_cond_t tgvoip_lock_t;

#define start_thread(ref, entry, arg) pthread_create(&ref, NULL, entry, arg)
#define join_thread(thread) pthread_join(thread, NULL)
#ifndef __APPLE__
#define set_thread_name(thread, name) pthread_setname_np(thread, name)
#else
#define set_thread_name(thread, name)
#endif
#define init_mutex(mutex) pthread_mutex_init(&mutex, NULL)
#define free_mutex(mutex) pthread_mutex_destroy(&mutex)
#define lock_mutex(mutex) pthread_mutex_lock(&mutex)
#define unlock_mutex(mutex) pthread_mutex_unlock(&mutex)
#define init_lock(lock) pthread_cond_init(&lock, NULL)
#define free_lock(lock) pthread_cond_destroy(&lock)
#define wait_lock(lock, mutex) pthread_cond_wait(&lock, &mutex)
#define notify_lock(lock) pthread_cond_broadcast(&lock)

#else
#error "No threading implementation for your operating system"
#endif

#endif //__THREADING_H
