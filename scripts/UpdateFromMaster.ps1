wget https://github.com/Kaleado/gmod-predator/archive/master.zip -OutFile master.zip
Expand-Archive -Path master.zip -DestinationPath ./
cp .\gmod-predator-master\* .\ -Force
rm .\gmod-predator-master\ -Recurse -Force
rm master.zip