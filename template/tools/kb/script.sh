#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/utils.sh

KB_URL="http://<:nginx_ip:>:9202/knowledgebase"

check_url "$KB_URL"

if [ $? -eq 0 ]; then
    echo "Knowledgebase already imported, do nothing."
    exit 0
fi

curl -s -XPUT "$KB_URL"

curl -s -XPOST $KB_URL/fulltext/_mapping -d '{"fulltext":{"_all":{"analyzer":"ik_max_word","search_analyzer":"ik_max_word","term_vector":"no","store":"false"},"properties":{"title":{"type":"text","store":"no","term_vector":"with_positions_offsets","analyzer":"ik_max_word","search_analyzer":"ik_max_word","include_in_all":"true","boost":8},"solution":{"type":"text","store":"no","term_vector":"with_positions_offsets","analyzer":"ik_max_word","search_analyzer":"ik_max_word","include_in_all":"true","boost":8},"symptom":{"type":"text","store":"no","term_vector":"with_positions_offsets","analyzer":"ik_max_word","search_analyzer":"ik_max_word","include_in_all":"true","boost":8}}}}'

echo

nohup <:install_root:>/supervisord/altenv/bin/python <:install_root:>/tools/kb/knowledgebase_spider/post.py <:install_root:>/tools/kb/knowledgebase_spider/data <:nginx_ip:>:9202 &

exit 0
