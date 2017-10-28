
<img src="https://blog-imgs-112.fc2.com/h/o/j/hojogames/2017y10m28d_185331276.png" alt="0" title="0">
<img src="https://blog-imgs-112.fc2.com/h/o/j/hojogames/2017y10m28d_185333159.png" alt="1" title="1">
<img src="https://blog-imgs-112.fc2.com/h/o/j/hojogames/2017y10m28d_185334576.png" alt="2" title="2">

# Hojo-Deferred-Water
UNITY向け、簡易ディファード水
G-Bufferを操作してそれっぽくすることにより、
追加のForward描画をせずに半透明の水を描画している
（いくつか制約はある）
詳細はかなり簡単なのでHojoDeferredWater.shaderの中身を見ればいい

# 使い方
HojoDeferredWaterCommandDispatcherの中を見ろ

超簡単に使いたい場合は
HojoDeferredWaterByMeshRendererが使える
Material waterMaterial
はHojoDeferredWater.shaderをマテリアルにしろ

# 用法
HDR,Deferredでのみ動くと思われる

# 謝罪
超適当にプロジェクトから持ってきたので、
HojoCharacterShaderLibrary.cgincとかCharacterShaderLibraryってなんやねん　的な
はいドンマイ～～～～
