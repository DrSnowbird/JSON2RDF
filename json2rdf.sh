#!/bin/bash

function usage() {
    echo "$(basename $0) -i <JSON_INPUT> [-o <TTL_OUTPUT>] [-b <BASE_URL>] [-v <VOCABULARY_FILE>] [--input-charset <INPUT_CHARSET>] [--output-charset <OUTPUT_CHARSET>]"
    if [ $# -lt 1 ]; then
        echo "Missing input JSON file! Abort!"
    fi
}

###################################################
#### ---- Change this only to use your own ----
###################################################
ORGANIZATION=${ORGANIZATION:-openkbs}
baseDataFolder="${HOME}/data-docker"

###################################################
#### **** Container package information ****
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${imageTag:-${ORGANIZATION}/${DOCKER_IMAGE_REPO}}

# `--input-charset` - JSON input encoding, by default UTF-8
# `--output-charset` - RDF output encoding, by default UTF-8

INPUT_CHARSET=
OUTPUT_CHARSET=
INPUT_CHARSET_ARGS=
OUTPUT_CHARSET_ARGS=
TTL_OUTPUT=
VOCABULARY_FILE=
while getopts "i:o:b:v:h-:" arg; do
  case $arg in
    -)
        case "${OPTARG}" in
            input-charset)
                INPUT_CHARSET="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                echo "Parsing option : '--${OPTARG}', INPUT_CHARSET: '${INPUT_CHARSET}'" >&2;
                ;;
            input-charset=*)
                INPUT_CHARSET=${OPTARG#*=}
                opt=${OPTARG%=$INPUT_CHARSET}
                echo "Parsing option: '--${opt}', INPUT_CHARSET: '${INPUT_CHARSET}'" >&2
                ;;
            output-charset)
                OUTPUT_CHARSET="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                echo "Parsing option : '--${OPTARG}', OUTPUT_CHARSET: '${OUTPUT_CHARSET}'" >&2;
                ;;
            output-charset=*)
                OUTPUT_CHARSET=${OPTARG#*=}
                opt=${OPTARG%=$OUTPUT_CHARSET}
                echo "Parsing option: '--${opt}', OUTPUT_CHARSET: '${OUTPUT_CHARSET}'" >&2
                ;;
            *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    echo "Unknown option --${OPTARG}" >&2
                fi
                ;;
        esac;;
    i)
      JSON_INPUT=${OPTARG}
      echo "JSON_INPUT=$JSON_INPUT"
      ;;
    o)
      TTL_OUTPUT=${OPTARG}
      echo "TTL_OUTPUT=$TTL_OUTPUT"
      ;;
    b)
      BASE_URL=${OPTARG}
      echo "BASE_URL=$BASE_URL"
      ;;
    v)
      VOCABULARY_FILE=${OPTARG}
      echo "VOCABULARY_FILE=$VOCABULARY_FILE"
      ;;
    h)
      usage "help"
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${JSON_INPUT}" ] ; then
    usage
    exit 1
fi

if [ -z "${TTL_OUTPUT}" ] ; then
    TTL_OUTPUT="${JSON_INPUT%.json}.ttl"
fi

if [ -z "${BASE_URL}" ] ; then
    BASE_URL="https://localhost/"
fi

# `--input-charset` - JSON input encoding, by default UTF-8
# `--output-charset` - RDF output encoding, by default UTF-8
if [ ! -z "${INPUT_CHARSET}" ] ; then
    INPUT_CHARSET_ARGS="--input-charset ${INPUT_CHARSET}"
    echo "INPUT_CHARSET_ARGS=$INPUT_CHARSET_ARGS"
fi

if [ ! -z "${OUTPUT_CHARSET}" ] ; then
    OUTPUT_CHARSET_ARGS="--output-charset ${OUTPUT_CHARSET}"
    echo "OUTPUT_CHARSET_ARGS=$OUTPUT_CHARSET_ARGS"
fi

echo "remaining args: $*"

######################################################
#### ---- Generate Ontology Vocabulary List ---- #####
######################################################
function generate_Ontology_Vocabulary() {
    echo
    echo "------------- Generating Vocabulary List: ${VOCABULARY_FILE} --------------"
    if [ ! -z "${VOCABULARY_FILE}" ] ; then
        cat $1 | cut -d'<' -f2|cut -d'>' -f1 |sort -u | tee ${VOCABULARY_FILE}
    else
        cat $1 | cut -d'<' -f2|cut -d'>' -f1 |sort -u
    fi
}

######################################################
#### ---- Generate RDF in Turtle format:    ---- #####
######################################################
#cat ordinary-json-document.json | docker run -i -a stdin -a stdout -a stderr atomgraph/json2rdf https://localhost/ | riot --formatted=TURTLE
#cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr atomgraph/json2rdf https://localhost/ | riot --formatted=TURTLE

echo

if [ "$TTL_OUTPUT" != "" ]; then
    echo "------------- Generating RDF in Tutrle (*.ttl) format: ${TTL_OUTPUT} --------------"
    cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr ${imageTag} ${BASE_URL} ${INPUT_CHARSET_ARGS} ${OUTPUT_CHARSET_ARGS} | tee ${TTL_OUTPUT}
    generate_Ontology_Vocabulary ${TTL_OUTPUT}
else
echo "------------- Generating RDF in Tutrle (*.ttl) format: --------------"
    cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr ${imageTag} ${BASE_URL} ${INPUT_CHARSET_ARGS} ${OUTPUT_CHARSET_ARGS} | tee .json-to-rdf-ttl.tmp
    generate_Ontology_Vocabulary .json-to-rdf-ttl.tmp
    rm -f .json-to-rdf-ttl.tmp
fi


