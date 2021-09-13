#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

mkdir -p ${path}


if [[ "none" == ${type} ]]; then
    if [[ ! -f "${path}/index.php" ]]; then
        touch "${path}/index.php"
    fi
elif [[ "laravel" == ${type} ]]; then
    if [[ ! -f "${path}/composer.json" ]]; then
        composer create-project laravel/laravel ${path}
    fi
elif [[ "ClassicPress" == ${type} ]]; then
    if [[ ! -f "${path}/wp-config.php" ]]; then
        wp core download  --path="${path}" https://classicpress.net/latest.zip
        wp config create --dbhost=localhost --dbname=${domain} --dbuser=classicpress --dbpass=classicpress  --path="${path}"
        wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email  --path="${path}"
        
        if [[ "${plugins}" != "none" ]]; then
          for plugin in ${plugins//- /$'\n'}; do
            if [[ "${plugin}" != "plugins" ]]; then
              wp plugin install ${plugin} --activate  --path="${path}"
            fi
          done
        fi

        if [[ "${themes}" != "none" ]]; then
          for theme in ${themes//- /$'\n'}; do
            if [[ "${theme}" != "themes" ]]; then
              wp theme install ${theme} --activate  --path="${path}"
            fi
          done
        fi

        if [[ "${constants}" != "none" ]]; then
          for const in ${constants//- /$'\n'}; do
            if [[ "${const}" != "constants" ]]; then
              wp config set --type=constant ${const} --raw true  --path="${path}"
            fi
          done
        fi
    fi
else
    if [[ ! -f "${path}/wp-config.php" ]]; then
        wp core download  --path="${path}"
        wp config create --dbhost=localhost --dbname=${domain} --dbuser=wordpress --dbpass=wordpress  --path="${path}"
        wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email  --path="${path}"

        if [[ "${ms}" == 'sub-domain' ]]; then
          wp core multisite-install --subdomains --url="${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email  --path="${path}"
        elif [[ "${ms}" == 'sub-directory' ]]; then
          echo "installing ${ms}"
          wp core multisite-install --url="${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email  --path="${path}"

        fi

        if [[ -d "${path}/wp-content/plugins/akismet" ]]; then
          wp plugin delete akismet  --path="${path}"
        fi 

        if [[ -f "${path}/wp-content/plugins/hello.php" ]]; then
          wp plugin delete hello  --path="${path}"
        fi 

        if [[ "${plugins}" != "none" ]]; then
          for plugin in ${plugins//- /$'\n'}; do
            if [[ "${plugin}" != "plugins" ]]; then
              wp plugin install ${plugin} --activate  --path="${path}"
            fi
          done
        fi

        if [[ "${themes}" != "none" ]]; then
          for theme in ${themes//- /$'\n'}; do
            if [[ "${theme}" != "themes" ]]; then
              wp theme install ${theme} --activate  --path="${path}"
            fi
          done
        fi

        if [[ "${constants}" != "none" ]]; then
          for const in ${constants//- /$'\n'}; do
            if [[ "${const}" != "constants" ]]; then
              wp config set --type=constant ${const} --raw true  --path="${path}"
            fi
          done
        fi
    fi
fi
