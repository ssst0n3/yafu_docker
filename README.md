# yafu-docker

unofficial container image for [yafu](https://github.com/bbuhrow/yafu)

```
docker run -ti ssst0n3/yafu:2.10
# yafu tune
# yafu -threads 128 -one
>> factor(2872432989693854281918578458293603200587306199407874717707522587993136874097838265650829958344702997782980206004276973399784460125581362617464018665640001)
```

## reference

* https://www.mersenneforum.org/showthread.php?t=23087
* https://www.mersenneforum.org/showthread.php?t=26764

## related project

There are some other images for yafu, but those seem missing some dependencies or only provide 1.34 version.

Yes, the yafu 2.0 has been already released. You can see [here](https://github.com/bbuhrow/yafu/blob/master/include/yafu.h#L25) to get the current version of yafu.

* https://hub.docker.com/r/eyjhb/yafu
* https://hub.docker.com/r/trapexit/yafu
* ...