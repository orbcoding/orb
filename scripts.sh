# Sourced by docker.sh so available through yarn d functionName
function deploy() { # Deploy repo, $arg1 = env, $arg2 = force
	if [[ $env == 'prod' ]]; then
		git push prod master #$force
		buildremote
	elif [[ $env == 'staging' ]]; then
		git push staging dev #$force
		buildremote
	else
		echo "No remotes for ${env}";
	fi
}

# function push() {
# 		# yarn d pull prod
# 	yarn d exec prod web "bundle install && yarn install && rails db:migrate"
# 	cp ../prod.env .env
# 	yarn d start prod

# 	#  && yarn d pruneall force

# 			# yarn d pull prod
# 		yarn d exec prod web "bundle install && yarn install && rails db:migrate"
# 		cp ../prod.env .env
# 		yarn d start prod
# 		#  && yarn d pruneall force
# }

function buildremote() {
	if [[ $env == 'prod' ]]; then
		ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
cd ${SRV_REPO_PATH}/${APP_NAME}-${env} && \
yarn d run ${env} web 'bundle install && \
yarn install --production && \
bundle exec rails db:migrate' \
&& yarn d start ${env}\
"
	elif [[ $env == 'staging' ]]; then
		ssh -t ${SRV_USER}@${SRV_DOMAIN} "\
cd ${SRV_REPO_PATH}/${APP_NAME}-${env} && \
bambod start -e staging &&
bambod run -e staging bundle install && \
yarn install --production' && \
bambod start -e -r staging && \
docker exec -it
"
	else
		echo "cant build $env"
	fi
}
# function getAll() { # Get from server, $arg1 = env
# 	getDb
# 	getFiles
# }

# function getDb() { # get db from srv, $arg1 = env
# 	ssh -t ${SRV_USER}@${SRV_DOMAIN} "docker exec -it ${APP_NAME}_prod_db mysqldump -u ${SRV_MYSQL_USER} -p${SRV_MYSQL_PASSWORD} ${SRV_MYSQL_DATABASE} > ${SRV_REPO_PATH}/backup.sql"
# 	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/backup.sql ./backup.sql
# 	ssh -t ${SRV_USER}@${SRV_DOMAIN} rm ${SRV_REPO_PATH}/backup.sql
# 	sed -i '1d' ./backup.sql # Make sure theres no trailing error
# 	docker exec -i ${APP_NAME}_dev_db mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < ./backup.sql
# 	# rm backup.sql
# }

# function getFiles() {
# 	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/_wordpress/wp-content/uploads ./_wordpress/wp-content/uploads --delete
# }
