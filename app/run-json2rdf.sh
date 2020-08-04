#!/bin/bash -x

function usage() {
    echo "$(basename $0) <JSON_INPUT> <TTL_OUTPUT>"
}
usage $*

# ---- main ----
URL_REF=https://example.com/test#

JAR=./target/json2rdf-1.0.1-jar-with-dependencies.jar

JSON_INPUT=${1:-./example.json}
TTL_OUTPUT=${2:-./${JSON_INPUT%.json}.ttl}

## java -jar json2rdf-1.0.1-jar-with-dependencies.jar http://example.com/test# < myinput.json > myoutput.ttl
#java -jar ${JAR} ${URL_REF} < ${JSON_INPUT} > ${TTL_OUTPUT}
cat ${JSON_INPUT} | java -jar ${JAR} ${URL_REF} | tee ${TTL_OUTPUT}

## cat test-input.json | java -jar json2rdf-1.0.1-jar-with-dependencies.jar https://localhost/ | riot --formatted=TURTLE
#cat ${JSON_INPUT} | java -jar ${JAR} ${URL_REF} | riot --formatted=TURTLE


#cat city-distances.json | docker run -i -a stdin -a stdout -a stderr atomgraph/json2rdf https://localhost/
