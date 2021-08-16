from typing import Any, Callable, Dict, Iterable, List, Mapping, Set, Union
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

    def __init__(
        self,
        group: None = None,
        target: Union[Callable[..., Any], None] = None,
        name: Union[str, None] = None,
        args: Iterable[Any] = (),
        kwargs: Union[Mapping[str, Any], None] = None,
        *,
        daemon: Union[bool, None] = None,
    ) -> None:
        super(PropagatingThread, self).__init__(
            group=group, target=target, name=name, args=args, kwargs=kwargs, daemon=daemon
        )
        self.exc = None
        self.ret = None

    def run(self) -> None:
        try:
            self.ret = self._target(*self._args, **self._kwargs)
        except BaseException as e:
            self.exc = e

    def join(self, timeout: Union[float, None] = None) -> Any:
        super(PropagatingThread, self).join(timeout=timeout)
        if self.exc:
            raise self.exc
        return self.ret


class PropagatingProcess(multiprocessing.Process):
    """
    Usage:
        num_proceses = 4
        processes = []
        for i in range(num_proceses):
            processes.append(PropagatingProcess(
                target=process_run,
            ))
        print("Test Start with num_proceses: %d" % (num_proceses))
        for process in processes:
            process.start()
        res = []
        for process in processes:
            res.append(process.join())
    """

    def __init__(
        self,
        group: None = None,
        target: Union[Callable[..., Any], None] = None,
        name: Union[str, None] = None,
        args: Tuple[Any, ...] = (),
        kwargs: Union[Mapping[str, Any], None] = None,
        *,
        daemon: Union[bool, None] = None,
    ) -> None:
        if kwargs is None or not "_queue" in kwargs:
            self.queue = multiprocessing.Queue()
            kwargs["_queue"] = self.queue
        super(PropagatingProcess, self).__init__(
            group=group, target=target, name=name, args=args, kwargs=kwargs, daemon=daemon
        )

    def run(self) -> None:
        assert self._kwargs is not None
        assert "_queue" in self._kwargs
        queue = self._kwargs.pop("_queue")

        try:
            ret = self._target(*self._args, **self._kwargs)
            queue.put(ret)
        except BaseException as e:
            queue.put(e)

    def join(self, timeout: Union[float, None] = None) -> Any:
        super(PropagatingProcess, self).join(timeout=timeout)
        ret = self.queue.get()
        if ret is not None and isinstance(ret, Exception):
            raise ret
        return ret


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
