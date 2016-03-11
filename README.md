# SESE Order Manager Prototypes

This repository contains very rough prototypes of various web frontends and
backends for an ERP/Order Manager. Right now just Ember.js & Yesod exist, but
Servant, Django Rest Framework, Angular prototypes are planned.


## Yesod

```
cabal install yesod-bin

cd yesod
cabal sandbox init
cabal install --only-dependencies
yesod devel
```


## Ember

```
cd ember
npm install
bower install
ember serve
```
