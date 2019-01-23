# gerrit-chinese-docker
Gerrit Docker For Chinese Language.

# Pull
## docker hub
```bash
# docker pull canvas1996/gerrit-2.16.3-chinese:latest
```

## aliyun docker hub
```bash
# docker pull registry.cn-hangzhou.aliyuncs.com/canvas/gerrit-2.16.3-chinese:latest
```

# Run
## docker hub
```bash
# docker run -ti -p 8080:8080 -p 29418:29418 canvas1996/gerrit-2.16.3-chinese:latest
```
## aliyun docker hub
```bash
# docker run -ti -p 8080:8080 -p 29418:29418 registry.cn-hangzhou.aliyuncs.com/canvas/gerrit-2.16.3-chinese:latest
```

# Port
- Web -- 8080
- SSH -- 29418

# Credits
[GerritCodeReview](https://github.com/GerritCodeReview) for GerritCodeReview SourceCode
