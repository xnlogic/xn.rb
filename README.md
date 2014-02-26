xn.rb
=====

Ruby API client for XN Logic based applications.

Synopsis
--------

Set up and authentication:
```
require 'rubygems'
require 'xn.rb'
api_session = Xn::XnApiSession.new 'https://app.lightmesh.com', 'my@email.com'
```
This will prompt the terminal for your password.  If you are not writing an interactive script, set the LMTOKEN environment variable first and the XnApiSession constructor will use that.
e.g.

```
~/my_project $ LMTOKEN='client_name XYZ1234' irb
2.1.0p0 :001 > require 'rubygems'
2.1.0p0 :002 > require 'xn.rb'
2.1.0p0 :003 > api_session = Xn::XnApiSession.new 'https://app.lightmesh.com', 'my@email.com'
2.1.0p0 :004 > Using token from env LMTOKEN
 => #<Xn::XnApiSession:0x007feef5c65070.....>
2.1.0p0 :005 > 
```

To query the API, there are a few helpers:
```
# NB: These two queries return subtly different results.  The first returns a Model record, with all Parts your user
# has access to, whereas the second returns just the Part data. For more on the difference between Models and Parts see:
# https://lightmesh.zendesk.com/entries/41374508-Concepts-Types-or-parts-and-Models for

response_hash = api_session.find_vertex_by_model 'ip', '/filter/name?name=10.0.0.2'
response_hash = api_session.find_vertex_by_part 'ip', '/filter/name?name=10.0.0.2'

# Create, Update, Find-or-Create:
new_ip_r_hash = api_session.create_vertex 'ip', name: '10.0.0.3', description: 'New reserved IP for projekt XYZ'
response_hash = api_session.update_vertex new_ip_r_hash,          description: 'New reserved IP for project XYZ'
response_hash = api_session.find_or_create_by_model_and_name('ip', '10.0.0.3', nil, description: 'New reserved IP for project XYZ')

# Get all related vertices:
api_session.related_vertices(new_ip_r_hash)

# Execute an action:
api_session.exec_action( new_ip_r_hash, 'set_subnet_from_ip', {} )  # Some actions take paramters in the form of a hash

```
We are always interested in hearing suggestions for more helpers (open an issue at https://github.com/xnlogic/xn.rb)

but you can also use the API http wrapper directly for more advanced use-cases:
```
api_session.api.get "/v1/is/ip/filters/name/properties/name/?name[regex]=^(?!10)" do |response|
  response.each do |id, ip|
    puts "IP: #{ip}, xnid: /model/ip/#{id}"
  end
end
```


