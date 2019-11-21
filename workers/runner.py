class RunnerError(Exception):
    pass

class Runner(object):
    """
    This class will run the functions that are supplied to it with the associated args.
    It keeps track of their start and end times, whether they're currently running, waiting,
    failed, or complete.

    Currently the attribute when calling this will be a list of tuples, where the first
    is a function that can be called, and the second is a tuple of args for that function.
    fns: [(fn1, args1), (fn1, args1), ...., (fnX, argsX)]
    """

    STATUSES = {
        0: 'waiting',
        1: 'running',
        2: 'failed',
        3: 'complete',
    }
    
    def __init__(self, fns):
        self._fns = []
        for fn_args in fns:
            if callable(fn_args) or len(fn_args) == 1:
                fn = fn_args[0]; args = (); kwargs = {}
            elif len(fn_args) == 2:
                fn = fn_args[0]; args = fn_args[1]; kwargs = {}
            elif len(fn_args) == 3:
                fn = fn_args[0]; args = fn_args[1]; kwargs = fn_args[2]
            elif len(fn_args) > 3:
                raise RunnerError(f'Either 1, 2, or 3 attributes are needed for each function.')
            elif not callable(fn) and not isinstance(fn, Runner):
                raise RunnerError(f'Init attribute is function is neither a function or Runner object: {fn.__name__} ')
            elif not args:
                raise RunnerError(f'Second paramater for args is not correct. args: {args}')
            elif type(kwargs) != dict:
                raise RunnerError(f'Third paramater for kwargs is not correct. kwargs: {kwargs}, type: {type(kwargs)}')
            self._fns.append((fn, args, kwargs))

    def run(self):
        for index, vals in enumerate(self._fns):
            _fn, _args, _kwargs = vals
            print(f'Running {_fn.__name__} with args {_args} and kwargs {_kwargs}.')
            try:
                if _args and _kwargs:
                    _fn(*_args, **_kwargs)
                elif _args:
                    _fn(*_args)
                elif _kwargs:
                    _fn(**_kwargs)
                else:
                    _fn()
            except Exception as e:
                print(e)
                print(f'Failed with function on index {index}: {e}')
                break
            print(f'Completed {_fn.__name__}')

    def status(self):
        pass
