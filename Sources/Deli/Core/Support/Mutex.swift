//
//  Mutex.swift
//  Deli
//

import Foundation

protocol MutexType {
    func sync<R>(execute: () -> R) -> R
}

final class Mutex: MutexType {

    // MARK: - Public

    func sync<R>(execute: () -> R) -> R {
	    pthread_mutex_lock(&unsafeMutex)
	    defer { pthread_mutex_unlock(&unsafeMutex) }
	    return execute()
    }

    // MARK: - Private

    private var unsafeMutex = pthread_mutex_t()

    // MARK: - Lifecycle

    init() {
	    var attr = pthread_mutexattr_t()
	    guard pthread_mutexattr_init(&attr) == 0 else {
    	    preconditionFailure()
	    }
	    pthread_mutexattr_settype(&attr, Int32(PTHREAD_MUTEX_NORMAL))

	    guard pthread_mutex_init(&unsafeMutex, &attr) == 0 else {
    	    preconditionFailure()
	    }
	    pthread_mutexattr_destroy(&attr)
    }
    deinit {
	    pthread_mutex_destroy(&unsafeMutex)
    }
}
