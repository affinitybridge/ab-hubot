var https = require('https'),
    _ = require('underscore');

module.exports = function () {
    var user, password,
        auth = null,
        domain = "{s}.unfuddle.com",
        headers = {'Accept': 'application/json'},
        version = 'v1',
        projects;

    var Unfuddle = function (subdomain, user, password) {
        domain = domain.replace('{s}', subdomain);
        auth = user + ':' + password;
    }

    Unfuddle.prototype.options = function (method, path) {
        return {
            host: domain,
            auth: auth,
            method: method,
            path: path,
            headers: headers
        }
    };

    Unfuddle.prototype.projects = function (cb) {
        this.request("GET", "projects", {
            200: function (data) {
                projects = JSON.parse(data);
                cb();
            }
        });
    };

    Unfuddle.prototype.ticket = function (project_id, number, cb) {
        if (!projects) {
            this.projects(function () {
                this.ticket(project_id, number, cb);
            }.bind(this));
            return;
        }

        project = _.find(projects, function (p) {
            return p.short_name === project_id || p.id === +project_id;
        });

        if (project) {
            var path = 'projects/' + project.id + '/tickets/by_number/' + number;
            this.request('GET', path, {
                200: function (data) {
                    cb(JSON.parse(data));
                },
                404: function (data) {
                    cb(null);
                }
            });
        }
        else {
            console.log("Project: " + project_id + ", doesn't exist");
            cb(null);
        }
    };

    Unfuddle.prototype.request = function (method, path, callbacks) {
        var options = this.options(method, '/api/' + version + "/" + path);

        var req = https.request(options, function (res) {
            var data = "";

            res.setEncoding('utf8');

            res.on('data', function (chunk) {
                data += chunk;
            });

            res.on('end', function () {
                if (res.statusCode in callbacks) {
                    callbacks[res.statusCode](data);
                }
                else {
                    unHandledHttpError(res.statusCode, res, data);
                }
            });
        });

        req.on('error', function (e) { error(e.message); });

        req.end();
    };

    Unfuddle.prototype.ticketUrl = function (ticket) {
        return "https://" + domain + "/projects/" + ticket.project_id + "/tickets/by_number/" + ticket.number;
    }

    function unHandledHttpError(code, res, data) {
        console.log("Unhandled HTTP Error: " + code);
    }

    function error(e) {
        console.log("Error: " + e);
    }

    return Unfuddle;
}();
