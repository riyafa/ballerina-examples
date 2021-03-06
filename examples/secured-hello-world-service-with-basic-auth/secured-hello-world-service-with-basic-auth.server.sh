# To perform authentication and authorization, credentials and related data are stored in a simple file-based
# user store. The `ballerina.conf` file is used for this purpose.
#
# To generate the file-based user store and insert relevant data, two sample bash scripts are used.
# These scripts will add user credentials, create the mapping between the user & groups, and create the mapping
# between the scopes & the groups.
#
# To generate the user store with user credentials, the following bash script can be used.
usage () {
    echo "Usage: bash userstore-generator.sh -u {username} -p {password} -g {comma separated groups} " 1>&2;
    exit 1;
}
generateUid () {
    echo -n ${1} | shasum -a 1 | awk '{print $1}'
}
generateHash () {
    echo -n ${1} | shasum -a 256 | awk '{print toupper($1)}'
}
writeToFile () {
    echo "# start of a user section" >> ${1}
    echo "[${2}]" >> ${1}
    echo "userid=\"${3}\"" >> ${1}
    echo "[${3}]" >> ${1}
    echo "password=\"${4}\"" >> ${1}
    if [[ ! -z ${5} ]]; then
        echo "groups=\"${5}\"" >> ${1}
    fi
    echo "# end of a user section" >> ${1}
    echo "" >> ${1}
    echo "userstore updated successfully with details of user: ${2}"
}
while getopts "u:p:g:" input; do
    case "${input}" in
        u)
            username=${OPTARG}
            ;;
        p)
            password=${OPTARG}
            ;;
        g)
            groups=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
if [ -z "${username}" ] || [ -z "${password}" ]; then
    usage
fi
writeToFile "ballerina.conf" "${username}" "$(generateUid ${username})" "$(generateHash ${password})" "${groups}"

# To use the script, create a file named `userstore-generator.sh`, copy the content to it, and execute it with the relevant
# parameters.
$ bash userstore-generator.sh -u {username} -p {password} -g {comma separated groups}

# To create the mapping between scopes and groups, the following bash script can be used.
usage () {
    echo "Usage: bash permissionstore-generator.sh -s {scope name} -g {comma separated groups} " 1>&2;
    exit 1;
}
writeToFile () {
    echo "# start of a permission section" >> ${1}
    echo "[${2}]" >> ${1}
    echo "groups=\"${3}\"" >> ${1}
    echo "# end of a permission section" >> ${1}
    echo "" >> ${1}
    echo "permissionstore updated successfully with details of scope: ${2}"
}
while getopts "s:g:" input; do
    case "${input}" in
        s)
            scope=${OPTARG}
            ;;
        g)
            groups=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
if [ -z "${scope}" ] || [ -z "${groups}" ]; then
    usage
fi
writeToFile "ballerina.conf" "${scope}" "${groups}"

# To use the script, create a file named `permissionstore-generator.sh` and execute it with the relevant
# parameters.
$ bash permissionstore-generator.sh -s {scope name} -g {comma separated groups}

# Create a file named `secured-hello-world-service-with-basic-auth.bal`, copy the code into it,
# and use the `ballerina run` command to start the service.
# Make sure the `ballerina.conf` file populated by the scripts given above is located in the
# same directory as the `secured-hello-world-service-with-basic-auth.bal` file.
$ ballerina run secured-hello-world-service-with-basic-auth.bal
ballerina: initiating service(s) in 'secured-hello-world-service-with-basic-auth.bal'
ballerina: started HTTPS/WSS endpoint 0.0.0.0:9090

# To build a compiled program file, use the
# `ballerina build` command followed by
# the service package name.
$ ballerina build secured-hello-world-service-with-basic-auth.bal
$ ls
secured-hello-world-service-with-basic-auth.balx	secured-hello-world-service-with-basic-auth.bal
