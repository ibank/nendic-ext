#!/bin/bash

# use extended globs
shopt -s extglob

release_path='../release'
src_path='../src'
package_path='../'

# 0. release 폴더를 초기화한다.
rm -r "$release_path" 2> /dev/null
mkdir "$release_path"
echo '[0] 릴리즈 폴더 초기화 완료'

# 1. 소스 폴더의 css를 복사한다.
mkdir "${release_path}/css"
cp ${src_path}/css/*.css ${release_path}/css/
echo '[1] CSS 복사 완료'

# 2. 소스 폴더의 이미지를 복사한다.
mkdir "${release_path}/img"
cp ${src_path}/img/*(*.jpg|*.png|*.gif) ${release_path}/img/ 
echo '[2] 이미지 복사 완료'

# 3. 스크립트 파일을 압축한다. (requiejs optimizer)
r.js -o build_bg.js
r.js -o build_cscript.js
echo '[3] 스크립트 압축 완료'

# 4. 매니페스트 파일을 릴리즈 폴더로 복사한다.
#    이 때, 스크립트 부분은 압축한 코드를 바라보도록 한다.
source replace_manifest.bash "${src_path}" "${release_path}"
echo '[4] 매니페스트 파일 수정/복사 완료'

# 5. 압축해서 package 폴더로 이동한다.
version_line=$(grep '"version"' ${src_path}/manifest.json)
r_version='"version": "(.+)"'
[[ "$version_line" =~ $r_version ]] && version=${BASH_REMATCH[1]}
(
  # zip release directory in sub shell
  cd ${release_path}
  zip -r ${package_path}/naver_endic_${version}.zip .
)
echo "[5] 릴리즈 폴더 압축 완료: v.$version"