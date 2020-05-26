#!/bin/bash

function usage() {
    echo "$(basename $0) -i <JSON_INPUT> [-o <TTL_OUTPUT>] [-b <BASE_URL>] [--input-charset <INPUT_CHARSET>] [--output-charset <OUTPUT_CHARSET>]"
    if [ $# -lt 1 ]; then
        echo "Missing input JSON file! Abort!"
    fi
}

# `--input-charset` - JSON input encoding, by default UTF-8
# `--output-charset` - RDF output encoding, by default UTF-8

INPUT_CHARSET=
OUTPUT_CHARSET=
INPUT_CHARSET_ARGS=
OUTPUT_CHARSET_ARGS=
TTL_OUTPUT=
while getopts "i:o:b:h-:" arg; do
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

#cat ordinary-json-document.json | docker run -i -a stdin -a stdout -a stderr atomgraph/json2rdf https://localhost/ | riot --formatted=TURTLE
#cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr atomgraph/json2rdf https://localhost/ | riot --formatted=TURTLE

if [ "$TTL_OUTPUT" != "" ]; then
    cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr openkbs/json2rdf-docker ${BASE_URL} ${INPUT_CHARSET_ARGS} ${OUTPUT_CHARSET_ARGS} | tee ${TTL_OUTPUT}
else
    cat ${JSON_INPUT} | docker run -i -a stdin -a stdout -a stderr openkbs/json2rdf-docker${BASE_URL} ${INPUT_CHARSET_ARGS} ${OUTPUT_CHARSET_ARGS} 
fi
