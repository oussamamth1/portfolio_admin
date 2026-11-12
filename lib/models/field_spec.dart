import 'package:flutter/material.dart' show IconData, Icons;

enum FieldType { text, multilineText, number, url, image, boolean, date, stringList }

class FieldSpec {
  const FieldSpec({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
  });

  final String key;
  final String label;
  final FieldType type;
  final bool required;
}

class ResourceConfig {
  const ResourceConfig({
    required this.title,
    required this.path,
    required this.fields,
    required this.titleField,
    this.subtitleField,
    this.icon = Icons.article_outlined,
  });

  final String title;
  final String path;
  final List<FieldSpec> fields;
  final String titleField;
  final String? subtitleField;
  final IconData icon;
}

final skillsConfig = ResourceConfig(
  title: 'Skills',
  path: '/me/skills',
  titleField: 'subject',
  subtitleField: 'category',
  icon: Icons.bolt_outlined,
  fields: const [
    FieldSpec(key: 'category', label: 'Category (e.g. Backend, Mobile)', type: FieldType.text, required: true),
    FieldSpec(key: 'subject', label: 'Skill name', type: FieldType.text, required: true),
    FieldSpec(key: 'level', label: 'Level (0-100)', type: FieldType.number, required: true),
    FieldSpec(key: 'icon_key', label: 'Icon key (code / server)', type: FieldType.text),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final languagesConfig = ResourceConfig(
  title: 'Languages',
  path: '/me/languages',
  titleField: 'language',
  icon: Icons.translate_outlined,
  fields: const [
    FieldSpec(key: 'language', label: 'Language', type: FieldType.text, required: true),
    FieldSpec(key: 'level', label: 'Proficiency (0-100)', type: FieldType.number, required: true),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final educationConfig = ResourceConfig(
  title: 'Education',
  path: '/me/education',
  titleField: 'institution',
  subtitleField: 'degree',
  icon: Icons.school_outlined,
  fields: const [
    FieldSpec(key: 'institution', label: 'Institution', type: FieldType.text, required: true),
    FieldSpec(key: 'degree', label: 'Degree', type: FieldType.text, required: true),
    FieldSpec(key: 'location', label: 'Location', type: FieldType.text),
    FieldSpec(key: 'period', label: 'Period (e.g. 2017 – 2022)', type: FieldType.text),
    FieldSpec(key: 'status', label: 'Status (e.g. Graduated)', type: FieldType.text),
    FieldSpec(key: 'description', label: 'Description', type: FieldType.multilineText),
    FieldSpec(key: 'coursework', label: 'Coursework (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'achievements', label: 'Achievements (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final certificationsConfig = ResourceConfig(
  title: 'Certifications',
  path: '/me/certifications',
  titleField: 'name',
  subtitleField: 'issuer',
  icon: Icons.workspace_premium_outlined,
  fields: const [
    FieldSpec(key: 'name', label: 'Name', type: FieldType.text, required: true),
    FieldSpec(key: 'issuer', label: 'Issuer', type: FieldType.text, required: true),
    FieldSpec(key: 'date', label: 'Date (e.g. 2025)', type: FieldType.text),
    FieldSpec(key: 'status', label: 'Status (e.g. Active)', type: FieldType.text),
    FieldSpec(key: 'credential_id', label: 'Credential ID', type: FieldType.text),
    FieldSpec(key: 'description', label: 'Description', type: FieldType.multilineText),
    FieldSpec(key: 'skills', label: 'Skill tags (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'url', label: 'Credential URL', type: FieldType.url),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final internshipsConfig = ResourceConfig(
  title: 'Experience',
  path: '/me/internships',
  titleField: 'company',
  subtitleField: 'role',
  icon: Icons.business_center_outlined,
  fields: const [
    FieldSpec(key: 'company', label: 'Company', type: FieldType.text, required: true),
    FieldSpec(key: 'role', label: 'Role', type: FieldType.text, required: true),
    FieldSpec(key: 'period', label: 'Period (e.g. 2022 – Present)', type: FieldType.text),
    FieldSpec(key: 'location', label: 'Location', type: FieldType.text),
    FieldSpec(key: 'type', label: 'Employment type (e.g. Full-time)', type: FieldType.text),
    FieldSpec(key: 'is_current', label: 'Current position', type: FieldType.boolean),
    FieldSpec(key: 'description', label: 'Description', type: FieldType.multilineText),
    FieldSpec(key: 'highlights', label: 'Highlights (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'techs', label: 'Tech stack (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'logo_url', label: 'Company logo', type: FieldType.image),
    FieldSpec(key: 'demo_url', label: 'Demo / app link', type: FieldType.url),
    FieldSpec(key: 'video_id', label: 'YouTube video ID', type: FieldType.text),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final projectsConfig = ResourceConfig(
  title: 'Projects',
  path: '/me/projects',
  titleField: 'title',
  subtitleField: 'status',
  icon: Icons.folder_outlined,
  fields: const [
    FieldSpec(key: 'title', label: 'Title', type: FieldType.text, required: true),
    FieldSpec(key: 'company', label: 'Company / context', type: FieldType.text),
    FieldSpec(key: 'period', label: 'Period (e.g. 2024–2025)', type: FieldType.text),
    FieldSpec(key: 'location', label: 'Location', type: FieldType.text),
    FieldSpec(key: 'description', label: 'Description', type: FieldType.multilineText),
    FieldSpec(key: 'icon_key', label: 'Icon key (briefcase / shield / smartphone / dumbbell)', type: FieldType.text),
    FieldSpec(key: 'category', label: 'Category (e.g. Mobile (Flutter))', type: FieldType.text),
    FieldSpec(key: 'technologies', label: 'Technologies (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'highlights', label: 'Highlights (comma separated)', type: FieldType.stringList),
    FieldSpec(key: 'status', label: 'Status (e.g. Published, In Progress)', type: FieldType.text),
    FieldSpec(key: 'image_url', label: 'Preview image', type: FieldType.image),
    FieldSpec(key: 'portrait', label: 'Portrait image layout', type: FieldType.boolean),
    FieldSpec(key: 'github_url', label: 'GitHub URL', type: FieldType.url),
    FieldSpec(key: 'app_store_url', label: 'App Store URL', type: FieldType.url),
    FieldSpec(key: 'play_store_url', label: 'Play Store URL', type: FieldType.url),
    FieldSpec(key: 'video_id', label: 'YouTube video ID', type: FieldType.text),
    FieldSpec(key: 'sort_order', label: 'Sort order', type: FieldType.number),
  ],
);

final profileConfig = ResourceConfig(
  title: 'Hero / Intro',
  path: '/me/profile',
  titleField: 'name',
  icon: Icons.badge_outlined,
  fields: const [
    FieldSpec(key: 'name', label: 'Name', type: FieldType.text, required: true),
    FieldSpec(key: 'title', label: 'Title', type: FieldType.text, required: true),
    FieldSpec(key: 'tagline', label: 'Tagline', type: FieldType.text),
    FieldSpec(key: 'bio', label: 'Bio', type: FieldType.multilineText),
    FieldSpec(key: 'phone', label: 'Phone (for tel: link)', type: FieldType.text),
    FieldSpec(key: 'email', label: 'Email (for mailto: link)', type: FieldType.text),
    FieldSpec(key: 'avatar_url', label: 'Avatar', type: FieldType.image),
    FieldSpec(key: 'resume_url', label: 'Resume (PDF URL)', type: FieldType.url),
    FieldSpec(key: 'cover_url', label: 'Cover / banner photo', type: FieldType.image),
    FieldSpec(key: 'cover_enabled', label: 'Show cover photo', type: FieldType.boolean),
    FieldSpec(key: 'linkedin_url', label: 'LinkedIn URL', type: FieldType.url),
    FieldSpec(key: 'github_url', label: 'GitHub URL', type: FieldType.url),
    FieldSpec(
      key: 'whatsapp_url',
      label: 'WhatsApp (e.g. https://wa.me/21600000000)',
      type: FieldType.url,
    ),
    FieldSpec(key: 'facebook_url', label: 'Facebook URL', type: FieldType.url),
    FieldSpec(key: 'instagram_url', label: 'Instagram URL', type: FieldType.url),
    FieldSpec(key: 'twitter_url', label: 'Twitter / X URL', type: FieldType.url),
  ],
);
