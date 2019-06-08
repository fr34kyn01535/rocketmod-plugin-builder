rm ./output/ -R
mkdir ./output/
docker build . -t rocketmod-plugin-builder:legacy
echo ">>>>>>>>>>>>>>>>>>>>>>>>" 
docker run \
 -v $(pwd)/output:/build/output \
 --name rocketmod-plugin-builder -it \
 -e GIT_REPOSITORY=https://github.com/fr34kyn01535/MessageAnnouncer.git \
 -e GIT_BRANCH=master \
 -e PROJECT_FILE=MessageAnnouncer.csproj \
 rocketmod-plugin-builder:legacy
echo "<<<<<<<<<<<<<<<<<<<<<<<<" 
docker rm -f rocketmod-plugin-builder 
docker rmi -f rocketmod-plugin-builder:legacy

 