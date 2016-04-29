class CompUnit::Repository::Unknown does CompUnit::Repository {

  # Just passes to next-repo unless there is no other repo
  method need(CompUnit::DependencySpecification $spec,
              CompUnit::PrecompilationRepository $precomp = self.precomp-repository()
  )
      returns CompUnit:D
  {
      return self.next-repo.need($spec, $precomp) if self.next-repo;
      X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
  }

  # Returns empty array as CURUs cannot return CUs
  method loaded()
      returns Iterable
      { [] }

  # Returns a unique ID of this repository
  method id()
      returns Str
      { ... }

  method precomp-repository()
      returns CompUnit::PrecompilationRepository
      { CompUnit::PrecompilationRepository::None }
}
