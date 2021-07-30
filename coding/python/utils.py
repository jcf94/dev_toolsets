from typing import Any, Dict, List, Set
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
    def __init__(self, group=None, target=None, name=None, args=(), kwargs=None, *, daemon=None):
        super(PropagatingThread, self).__init__(
            group=group, target=target, name=name, args=args, kwargs=kwargs, daemon=daemon,
        )
        self.exc = None
        self.ret = None

    def run(self):
        try:
            self.ret = self._target(*self._args, **self._kwargs)
        except BaseException as e:
            self.exc = e

    def join(self):
        super(PropagatingThread, self).join()
        if self.exc:
            raise self.exc
        return self.ret


def IsEmpty(target: Any) -> bool:
    """Check if a target is empty.

    Parameters
    ----------
    target : Any

    Returns
    -------
    bool
        If the target is empty.
    """
    if target is None:
        return True

    if isinstance(target, (Dict, List, Set)) and len(target) == 0:
        return True

    try:
        import numpy as np
    except Exception:
        pass
    else:
        if isinstance(target, np.ndarray) and target.size == 0:
            return True

    return bool(target)
