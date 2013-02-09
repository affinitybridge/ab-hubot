var https = require('https'),
    _ = require('underscore'),
    RSVP = require('rsvp'),
    restify = require('restify');

module.exports = function () {

    var client,
        domain = "https://{s}.unfuddle.com",
        version = 'v1',
        cache = {
            projects: [],
            tickets: []
        };

    var Unfuddle = function (subdomain, user, password) {
        client = restify.createJsonClient({
            url: domain.replace('{s}', subdomain)
        });
        client.basicAuth(user, password);
    }

    Unfuddle.prototype.ticket = function (project_id, number) {
        var promise = new RSVP.Promise(),
            ticket = this.checkCache('tickets', function (t) {
                return t.number === number && t.project_id === project_id;
            });

        if (ticket) {
            promise.resolve(ticket);
        }
        else {
            var path = '/api/{v}/projects/{id}/tickets/by_number/{number}'
                        .replace('{v}', version)
                        .replace('{number}', number);

            this.project(project_id).then(function (project) {
                path = path.replace('{id}', project.id);

                client.get(path, function (err, req, res, obj) {
                    if (err) promise.reject({ err: err, req: req, res: res, obj: obj });
                    cache.tickets.push(obj);
                    promise.resolve(obj);
                });
            },
            function (error) {
                promise.reject(error);
            });
        }

        return promise;
    };

    Unfuddle.prototype.projects = function () {
        var promise = new RSVP.Promise();

        if (cache.projects.length) {
            promise.resolve(cache.projects)
        }
        else {
            client.get('/api/' + version + '/projects', function (err, req, res, obj) {
                if (err) promise.reject({ err: err, req: req, res: res, obj: obj });

                cache.projects = obj;
                promise.resolve(obj);
            });
        };

        return promise;
    };

    Unfuddle.prototype.project = function (id) {
        var promise = new RSVP.Promise(),
            project = this.checkCache('projects', function (p) {
                return p.id === +id|| p.short_name === id;
            });

        if (project) {
            promise.resolve(project);
        }
        else {
            var success = function (project) {
                    promise.resolve(project);
                },
                error = function (err) {
                    promise.reject(err);
                };

            // First try short name.
            this.projectByShortName(id).then(success, function (err) {
                if (err.statusCode === 404) {
                    // Otherwise try id and if that fails, error out.
                    this.projectById(id).then(success, error);
                }
                else {
                    promise.reject(err);
                }
            }.bind(this));
        }

        return promise;
    };

    Unfuddle.prototype.projectById = function (id) {
        var promise = new RSVP.Promise();

        var path = '/api/{v}/projects/{id}'
                        .replace('{v}', version)
                        .replace('{id}', id);

        client.get(path, function (err, req, res, obj) {
            if (err) {
                if (err.statusCode === 404) {
                    err = new restify.ResourceNotFoundError("Project: '" + id + "', not found");
                }
                promise.reject(err);
            }

            cache.projects.push(obj);
            promise.resolve(obj);
        });

        return promise;
    };

    Unfuddle.prototype.projectByShortName = function (name) {
        var promise = new RSVP.Promise();

        var path = '/api/{v}/projects/by_short_name/{name}'
                    .replace('{v}', version)
                    .replace('{name}', name);

        client.get(path, function (err, req, res, obj) {
            if (err) {
                if (err.statusCode === 404) {
                    err = new restify.ResourceNotFoundError("Project: '" + name + "', not found");
                }
                promise.reject(err);
            }

            cache.projects.push(obj);
            promise.resolve(obj);
        });

        return promise;
    };

    Unfuddle.prototype.checkCache = function (bin, condition) {
        if (bin in cache && cache[bin].length) {
            return _.find(cache[bin], condition);
        }
    };

    Unfuddle.prototype.ticketUrl = function (ticket) {
        return "https://" + domain + "/projects/" + ticket.project_id + "/tickets/by_number/" + ticket.number;
    };

    return Unfuddle;
}();
