#!/bin/bash

cd /build

if [[ -z "${GIT_BRANCH}" ]]; then
  GIT_BRANCH="master"
fi

if [[ -z "${GIT_REPOSITORY}" ]]; then
  echo -e "GIT_REPOSITORY must be specified!"
  exit
fi

echo -e "\nFetching repository..."
git clone --single-branch --branch $GIT_BRANCH $GIT_REPOSITORY /build/workspace

echo -e "\nFetching latest RocketMod binaries..."
mkdir -p "/build/workspace/lib/"
curl https://ci.rocketmod.net/job/Rocket.Unturned/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip -o Rocket.zip
unzip -joq Rocket.zip "Modules/Rocket.Unturned/*.dll" -d "/build/workspace/lib/" 

echo -e "\nStarting the build process..."
cd /build/workspace

if [[ -z "${PROJECT_FILE}" ]]; then
  echo -e "PROJECT_FILE is not set, guessing it"
  PROJECT_FILE=$(ls *.csproj | head -1)
fi

msbuild /p:Configuration=Release /p:DebugSymbols=false /p:TargetFrameworkVersion="v4.0" /p:PreBuildEvent= /p:PostBuildEvent= /p:OutDir=/build/output/ $PROJECT_FILE
mkdir /build/dist/harbor -p
echo -e "\nAnalysing build output..."
assembly=$(cat $PROJECT_FILE | grep -oPm1 "(?<=<AssemblyName>)[^<]+").dll 
echo -e "The assembly is $assembly"
pluginName="${assembly%.*}" 
echo -e "Assuming the plugins name is $pluginName"

cp "/build/output/$pluginName.dll" /build/workspace/lib/
cp /build/Rocket.RepositoryHelper.exe /build/workspace/lib/

mono /build/workspace/lib/Rocket.RepositoryHelper.exe "/build/workspace/lib/$pluginName.dll"

mv ./commands.xml /build/dist/harbor
mv ./translation.xml /build/dist/harbor
mv ./configuration.xml /build/dist/harbor

#TODO END
git log -1 --pretty=%B > /build/dist/harbor/git-commit-message.txt
