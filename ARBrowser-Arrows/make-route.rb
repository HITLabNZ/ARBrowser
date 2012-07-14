#!/usr/bin/env ruby

points_text = <<EOF
-43.516175, 172.554341
-43.516110, 172.553260
-43.518735, 172.551792
-43.518942, 172.552447
-43.518927, 172.553142
-43.519803, 172.556773
-43.519086, 172.557218
-43.518757, 172.557619
-43.517703, 172.557965
-43.516971, 172.557993
-43.516791, 172.557613
-43.516726, 172.555941
-43.516232, 172.554415
-43.516179, 172.554492
EOF

prefix = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>points</key>
	<array>
EOF

postfix = <<EOF
	</array>
</dict>
</plist>
EOF

puts prefix

points_text.scan(/([0-9\.\-]+), ([0-9\.\-]+)/) do |match|
	latitude = match[0].to_f
	longitude = match[1].to_f

	puts <<EOF
		<dict>
			<key>latitude</key>
			<real>#{latitude}</real>
			<key>longitude</key>
			<real>#{longitude}</real>
			<key>metadata</key>
			<dict>
				<key>icon</key>
				<string></string>
				<key>directions</key>
				<string></string>
			</dict>
		</dict>
EOF

end

puts postfix