# Интеграция 3DS2 SDK

## 3DS2

Для интеграции 3DS2_SDK необходимо:
1. Скачать ThreeDSSDK.xcframework и добавить в проект;

<div align="center">
  <img src="./images/3DS2/add_framework.png" width="600"/>
</div>

2. Указать в tagrete -> general ThreeDSSDK.xcframework как `Embed & Sign`;

<div align="center">
  <img src="./images/3DS2/setting_framework.png" width="600"/>
</div>

3. Импортировать ThreeDSSDK.

```swift
import ThreeDSSDK
...
```
