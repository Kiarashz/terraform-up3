output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

output "for_directive" {
  value = "%{for name in var.hero_thousand_faces}${name}, %{endfor}"
}

output "for_directive_index_if_else_strip" {
  value = <<EOF
%{~for i, name in keys(var.hero_thousand_faces)~}
${name}%{if i < length(var.hero_thousand_faces) - 1}, %{else}.%{endif}
%{~endfor~}
EOF
}
