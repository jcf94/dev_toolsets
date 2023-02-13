from multiprocessing import Process, Condition, Manager, RLock
import time
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format="(%(threadName)-9s) %(message)s",
)


def consumer(work: Condition, finish: Condition, dd):
    logging.debug("Consumer thread started ...")
    with work:
        logging.debug("Consumer waiting ...")
        work.wait()
        logging.debug("Consumer consumed the resource, %d", dd[0])
        dd[1] -= 1
        finish.notify()


def producer(work: Condition, finish: Condition, dd):
    logging.debug("Producer thread started ...")
    while True:
        with work:
            logging.debug("Making resource available")
            logging.debug("Notifying to all consumers")
            dd[0] = dd[0] + 2
            work.notify()
            finish.wait()
            if dd[1] <= 0:
                return


if __name__ == "__main__":

    with Manager() as mm:
        data = mm.list(range(10))
        # [data, flag]

        num = 5
        data[1] = num

        lock = RLock()
        work_cv = Condition(lock)
        finish_cv = Condition(lock)

        cs = []
        for i in range(num):
            cs.append(Process(name="consumer", target=consumer, args=(work_cv, finish_cv, data)))
            cs[-1].start()

        pd = Process(name="producer", target=producer, args=(work_cv, finish_cv, data))
        pd.start()
        pd.join()
        for t in cs:
            t.join()
