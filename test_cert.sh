#!/bin/sh

# Script de recuperation du nombre de jours avant expiration du certificat
#  Ne pas oublier de renseigner le fichier /etc/hosts avec l'adresse ip + fqdn

sniSupport=false
displayDate=false
prgName=$(readlink -m $0)
outCert="$(mktemp /tmp/cert.XXXXX)"
outCertChain="$(mktemp /tmp/certChain.XXXXX)"

while getopts "sdu:c:w:" opt; do
  case "$opt" in
      u) url=$OPTARG ;;
      c) crit_age=$OPTARG ;;
      w) warn_age=$OPTARG ;;
      s) sniSupport=true;;
      d) displayDate=true;;
  esac
done
shift $((OPTIND-1))

if test -z "$url" || test -z "$crit_age" || test -z "$warn_age"; then
    echo "Usage : ${prgName##*/} [-d] [-s] -w warn_age -c crit_age -u <fqdn>"
    echo ""
    echo "   -s : to support SNI"
    echo "   -d : to display the expiration date"
    echo ""
    echo "Exemples :"
    echo "    $prgName -w 60 -c 30 -u lifenet.swisslife-select.at"
    echo "    $prgName -w 60 -c 30 -s -u klient.swisslifeselect.cz"
    exit 0
fi

if (( $crit_age > $warn_age )); then
    echo "The crit_age should be < than warn_age"
    exit 0
fi

rc=0
if [ "$sniSupport" = false ]; then
    # Without SNI Support
    openssl s_client -connect "$url":443 </dev/null 2>&1 |\
        sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > ${outCert}
    rc=$(($rc+$?))
    openssl s_client -connect "$url":443 </dev/null 2>&1 |\
        sed -n '/Certificate chain/,/---/p' > ${outCertChain}
    rc=$(($rc+$?))
else
    # SNI Support
    openssl s_client -servername "$url" -connect "$url":443 </dev/null 2>&1 |\
        sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > ${outCert}
    rc=$(($rc+$?))
    openssl s_client -servername "$url" -connect "$url":443 </dev/null 2>&1 |\
        sed -n '/Certificate chain/,/---/p' > ${outCertChain}
    rc=$(($rc+$?))

fi
if test $rc -ne 0; then
    echo 'Alert: error during the openssl s_client call'
    rm -f ${outCert} ${outCertChain}
    exit 1
fi

endDate=$(cat ${outCert} |\
    openssl x509 -noout -enddate |\
    sed -n 's/notAfter=//p')


epochDate=$(date --date "$endDate" +%s)
if [ "$displayDate" = true ]; then
    echo "Expiration date : " $endDate
    echo "Certificat chain "
    cat ${outCertChain}
    echo "------------------"
fi

epochNow=$(date +%s)

expiration_days=$(( ($epochDate - $epochNow)/86400 ))

if (( ${expiration_days} <= ${crit_age} )); then
    printf "Critical : the certificate expires in %s days\n" $expiration_days
    printf "Certificate chain : "
    cat ${outCertChain}
elif (( ${expiration_days} > ${crit_age} )) && ((${expiration_days} <= ${warn_age} )); then
    printf "Warning : the certificate expires in %s days\n" $expiration_days
    printf "Certificate chain : "
    cat ${outCertChain}
else
    printf "The certificate expires in %s days\n" $expiration_days
fi

rm -f ${outCert} ${outCertChain}
exit 0
