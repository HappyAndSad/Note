## brew换源
转自：https://blog.csdn.net/gorwayne/article/details/107359912

### 第一步，替换brew.git


```
cd "$(brew --repo)"
git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
```
### 第二步：替换homebrew-core.git


```
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
```

### 第三步：替换homebrew-cask默认源

```
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask"
git remote set-url origin git://mirrors.ustc.edu.cn/homebrew-cask.git
```

### 第四步：替换homebrew-bottle默认源

```
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bashrc
source ~/.bashrc
```

### 最后使用
```
brew update --verbose
```