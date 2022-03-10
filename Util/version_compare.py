import sys


if len(sys.argv) == 3:
    file_name, version1,version2 = sys.argv
else:
    print ('Too many/few arguments passed.')


def compare_version(a1, a2):
    val1 = tuple(map(int,(a1.split('.'))))
    val2 = tuple(map(int,(a2.split('.'))))

    if val1 > val2:
        print(1)
    elif val1 < val2:
        print(-1)
    else:
        print (0)


compare_version(version1,version2)