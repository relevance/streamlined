CREATE TABLE `people` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(50) default NULL,
  `last_name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `poets` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(50) default NULL,
  `last_name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `poems` (
  `id` int(11) NOT NULL auto_increment,
  `text` varchar(50) default NULL,
  `poet_id` int(11),
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `authors` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(50) default NULL,
  `last_name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `authorships` (
  `author_id` int(11) NOT NULL,
  `publication_id` int(11) NOT NULL,
  `publication_type` varchar(255) default NULL
) TYPE=InnoDB;

CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `author_id` int(11),
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `books` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `author_id` int(11),
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;
