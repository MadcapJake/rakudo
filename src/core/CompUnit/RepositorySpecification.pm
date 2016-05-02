class CompUnit::RepositorySpecification {
    has Str:D $.short-id is required;
    has Str:D $.url is required;
    has %.options;

    method Str(CompUnit::RepositorySpecification:D:) {
        join '#', $!short-id,
            |("$_.key()[$_.key()]" for %!options.pairs),
            $!url;
    }

    method parse(CompUnit::RepositorySpecification:U:
        Str:D $spec,
        Str:D $default-short-id = 'file'
    ) returns CompUnit::RepositorySpecification:D {
        my %options;

        if $spec ~~ /
          ^ [
            $<type>=[ <.ident>+ % '::' ]
            [ '#' $<n>=\w+
              <[ < ( [ { ]> $<v>=<[\w-]>+ <[ > ) \] } ]>
              { %options{$<n>} = ~$<v> }
            ]*'#'
          ]? $<url>=.* $
        / {
            self.bless:
                :short-id($<type> ?? ~$<type> !! $default-short-id)
                :%options
                :url($<url>.Str)
        }
    }

    method parse-all(CompUnit::RepositorySpecification:U:
        Str:D $specs
    ) returns Array[CompUnit::RepositorySpecification:D] {
        my @found := Array[CompUnit::RepositorySpecification:D].new;
        my $default-short-id = 'file';

        if $*RAKUDO_MODULE_DEBUG -> $RMD { $RMD("Parsing specs: $specs") }

        for $specs.pslit(/ \s* ',' \s* /) -> $spec {
            if self.parse($spec, $default-short-id) -> $rspec {
                @found.push: ~$rspec;
                $default-short-id = $rspec.short-id
            }
            elsif $spec {
                die "Don't know how to handle $spec";
            }
        }
        @found
    }
}
