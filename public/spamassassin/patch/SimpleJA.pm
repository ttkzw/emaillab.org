# <@LICENSE>
# Copyright 2004 Apache Software Foundation
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

=head1 NAME

Tokenizer::SimpleJA - simple Japanese tokenizer

=head1 SYNOPSIS

loadplugin     Mail::SpamAssassin::Plugin::Tokenizer::SimpleJA

=head1 DESCRIPTION

This plugin simply tokenizes a Japanese string by characters other than 
the alphabet, the Chinese character, and the katakana. 

=cut

package Mail::SpamAssassin::Plugin::Tokenizer::SimpleJA;

use Mail::SpamAssassin::Plugin::Tokenizer;
use strict;
use warnings;
use bytes;

use vars qw(@ISA);
@ISA = qw(Mail::SpamAssassin::Plugin::Tokenizer);

our $language = 'ja';

our $RE = qr{(
  # ASCII
    [\x00-\x7F]+
  # Katakana
  | (?:
        \xE3\x82[\xA0-\xBF]
      | \xE3\x83[\x80-\xBF]
    )+
  # Kanji
  | (?:
        \xE3[\x90-\xBF][\x80-\xBF]
      | [\xE4-\xE9][\x80-\xBF]{2}
      | \xEF[\xA4-\xAB][\x80-\xBF]
    )+
  # Others
  | [\xC0-\xDF][\x80-\xBF]
  | [\xE0-\xE2][\x80-\xBF]{2}
  | \xE3[\x80-\x81][\x80-\xBF]
  | \xE3\x82[\x80-\x9F]
  | \xE3[\x84-\x8F][\x80-\xBF]
  | [\xEA-\xEE][\x80-\xBF]{2}
  | \xEF[\x80-\xA3][\x80-\xBF]
  | \xEF[\xAC-\xBF][\x80-\xBF]
  | [\xF0-\xF7][\x80-\xBF]{3}
)}x;

sub new {
  my $class = shift;
  my $mailsaobject = shift;

  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsaobject, $language);
  bless ($self, $class);

  return $self;
}

sub tokenize {
  my $self = shift;
  my $text_array = shift;

  my @tokenized_array;
  foreach my $text (@$text_array) {
    unless ($text and $text =~ /[\x80-\xFF]/) {
      push(@tokenized_array, $text);
      next;
    }

    my $tokenized = $text;
    $tokenized =~ s/$RE/$1 /og;
    push(@tokenized_array, $tokenized);
  }
  return \@tokenized_array;
}

1;
