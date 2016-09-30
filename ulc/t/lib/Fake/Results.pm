# Copyright 2016 cPanel, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package Fake::Results;

sub new {
    my ($class, %opts) = @_;

    my $now =  time();
    my $self = bless {
        (%opts)
    }, $class;

    return  $self;
}

sub error {
    my $self = shift;
    $self->{error} = \@_ if @_;
    return $self->{error};
}

sub data {
    my $self = shift;
    $self->{data} = $_[0] if $_[0];
    return $self->{data};
}

1;


