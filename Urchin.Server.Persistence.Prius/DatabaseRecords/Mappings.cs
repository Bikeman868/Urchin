namespace Urchin.Server.Persistence.Prius.DatabaseRecords
{
    public class Mappings : AutoMapper.Profile
    {
        public override string ProfileName
        {
            get { return "PriusContracts"; }
        }

        protected override void Configure()
        {
            CreateMap<EnvironmentRecord, Shared.DataContracts.EnvironmentDto>()
                .ForMember(
                    dest => dest.Machines,
                    opt => opt.Ignore())
                .ForMember(
                    dest => dest.SecurityRules,
                    opt => opt.Ignore());

            CreateMap<VariableRecord, Shared.DataContracts.VariableDeclarationDto>();

            CreateMap<RuleRecord, Shared.DataContracts.RuleDto>()
                .ForMember(
                    dest => dest.Variables,
                    opt => opt.Ignore())
                .ForMember(
                    dest => dest.EvaluationOrder,
                    opt => opt.Ignore());
        }
    }
}
