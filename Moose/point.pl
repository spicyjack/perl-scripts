  package Point;
  use Moose;
        
  has 'x' => (isa => 'Int', is => 'ro');
  has 'y' => (isa => 'Int', is => 'rw');
  
  sub clear {
      my $self = shift;
      $self->{x} = 0;
      $self->y(0);    
  }
  
  package Point3D;
  use Moose;
  
  extends 'Point';
  
  has 'z' => (isa => 'Int');
  
  after 'clear' => sub {
      my $self = shift;
      $self->{z} = 0;
  };

package main;
use Moose;

my $point = Point->new(x => 3, y => 5);
print qq(X is ) . $point->x . qq(\n);
