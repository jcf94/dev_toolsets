import threading

class PropagatingThread(threading.Thread):
    """
    Usage:
        num_threads = 4
        threads = []
        for i in range(num_threads):
            threads.append(PropagatingThread(
                target=process_run,
            ))
        print("Test Start with num_threads: %d" % (num_threads))
        for thread in threads:
            thread.start()
        res = []
        for thread in threads:
            res.append(thread.join())
    """
    def run(self):
        self.exc = None
        try:
            self.ret = self._target(*self._args, **self._kwargs)
        except BaseException as e:
            self.exc = e

    def join(self):
        super(PropagatingThread, self).join()
        if self.exc:
            raise self.exc
        return self.ret
