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

# non-type constraint usage
#my $point = Point->new(x => 3, y => 5);
#print qq(X is ) . $point->x . qq(\n);

# usage with type constraints
my $point;
#my $xval = 'fourty-two';
my $xval = 42;
my $xattribute = Point->meta->find_attribute_by_name('x');
my $xtype_constraint = $xattribute->type_constraint;
if($xtype_constraint->check($xval)) {
    $point = Point->new(x => $xval, y => 0);
} else {
    print "Value: $xval is not an " . $xtype_constraint->name . "\n";
}
