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

    def __init__(self):
        self.operator = {}
        self.top_level = []

    def add(self, name, fn, parents=[]):
        if name in self.operator:
            raise RunnerError(f"Action's name {name} has already been added. Please choose a different name.")
        invalid_parents = []
        for parent in parents:
            if parent not in self.operator:
                invalid_parents.append(parent)
        if invalid_parents:
            raise RunnerError(f"Parent name {name} has not been declared. Make sure to add parent first.")

        self.operator[name] = {}
        self.operator[name]['fn'] = fn
        self.operator[name]['children'] = [] #defining the children

        for parent in parents:
            self.operator[parent]['children'].append(name)

    def call(self, name, *args, **kwargs):
        op = self.operator[name]
        fn = op['fn']
        children = op['children']
        print(f'Running {name} with args {args} and kwargs {kwargs}.')
        try:
            retval = fn(*args, **kwargs)
            for child in children:
                self.call(child, retval)
            pass
        except Exception as e:
            print(e)
            print(f'Failed with function{e}')
            raise(e)
        print(f'Completed {fn.__name__}')

def say(line):
    print(line)
    return f"{line} to child"

def say2(line):
    print(f'2 {line}')

if __name__ == '__main__':
    runner = Runner()
    runner.add('say', say)
    runner.add('say2', say2, parents=['say'])
    runner.call('say', 'this')
    runner.call('say2', 'this2')
